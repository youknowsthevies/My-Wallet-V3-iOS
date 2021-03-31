//
//  ExchangeAccountsProvider.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/4/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift
import ToolKit

public protocol ExchangeAccountsProviderAPI {
    var accounts: Single<[CryptoExchangeAccount]> { get }
    func account(for currency: CryptoCurrency) -> Single<CryptoExchangeAccount?>
}

final class ExchangeAccountsProvider: ExchangeAccountsProviderAPI {
    
    // MARK: - Public (ExchangeAccountsProviderAPI)
    
    var accounts: Single<[CryptoExchangeAccount]> {
        exchangeAccountsCachedValue.valueSingle
    }
    
    // MARK: - Private Properties
    
    private let exchangeAccountsCachedValue: CachedValue<[CryptoExchangeAccount]>
    private let statusService: ExchangeAccountStatusServiceAPI
    private let client: ExchangeAccountsProviderClientAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(client: ExchangeAccountsClientAPI = resolve(),
         statusService: ExchangeAccountStatusServiceAPI = resolve()) {
        self.statusService = statusService
        self.client = client
        exchangeAccountsCachedValue = CachedValue<[CryptoExchangeAccount]>(
            configuration: CachedValueConfiguration(
                refreshType: .onSubscription,
                flushNotificationName: .logout,
                fetchNotificationName: .login
            )
        )

        exchangeAccountsCachedValue.setFetch {
            statusService.hasLinkedExchangeAccount
                .map { hasLinkedExchangeAccount -> Void in
                    guard hasLinkedExchangeAccount else {
                        throw ExchangeAccountsNetworkError.missingAccount
                    }
                    return ()
                }
                .flatMap { .just(CryptoCurrency.allCases) }
                .flatMap { currencies -> Single<[CryptoExchangeAccount]> in
                    let elements = currencies.map { currency in
                        client
                            .exchangeAddress(with: currency)
                            .map { response in
                                CryptoExchangeAccount(response: response)
                            }
                    }
                    
                    return Single.zip(elements)
                }
        }
        
        setup()
    }
    
    // MARK: - ExchangeAccountsProviderAPI
    
    func account(for currency: CryptoCurrency) -> Single<CryptoExchangeAccount?> {
        exchangeAccountsCachedValue
            .valueSingle
            .map { accounts in
                let account = accounts.filter { $0.asset == currency }.first
                guard let value = account else {
                    throw ExchangeAccountsNetworkError.missingAccount
                }
                return value
            }
    }
    
    // MARK: - Private Functions
    
    private func setup() {
        /// Fetch the users accounts upon initialization.
        /// Subsequent calls should be pulled from cache.
        /// Logout purges cache. Login refreshes cache. 
        accounts
            .observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
