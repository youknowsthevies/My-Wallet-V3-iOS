// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import RxSwift
import ToolKit

public protocol ExchangeAccountsProviderAPI {
    func account(for currency: CryptoCurrency) -> Single<CryptoExchangeAccount>
}

final class ExchangeAccountsProvider: ExchangeAccountsProviderAPI {

    // MARK: - Private Properties

    private let statusService: ExchangeAccountStatusServiceAPI
    private let client: ExchangeAccountsProviderClientAPI
    private let disposeBag = DisposeBag()
    private let storage: Atomic<[CryptoCurrency: CryptoExchangeAccount]> = .init([:])

    // MARK: - Init
    
    init(client: ExchangeAccountsClientAPI = resolve(),
         statusService: ExchangeAccountStatusServiceAPI = resolve()) {
        self.statusService = statusService
        self.client = client
    }

    // MARK: - ExchangeAccountsProviderAPI

    func account(for currency: CryptoCurrency) -> Single<CryptoExchangeAccount> {
        guard let account = storage.value[currency] else {
            Logger.shared.debug("Cache Miss: \(currency.code)")
            return fetchAccount(for: currency)
        }
        Logger.shared.debug("Cache Hit: \(currency.code)")
        return .just(account)
    }

    private func fetchAccount(for currency: CryptoCurrency) -> Single<CryptoExchangeAccount> {
        client.exchangeAddress(with: currency)
            .map { response in
                CryptoExchangeAccount(response: response)
            }
            .do(onSuccess: { [weak self] account in
                self?.storage.mutate { cache in
                    cache[currency] = account
                }
            })
            .catchError { error -> Single<CryptoExchangeAccount> in
                Logger.shared.debug("Fetch Error: \(currency.code)")
                throw ExchangeAccountsNetworkError.missingAccount
            }
    }
}
