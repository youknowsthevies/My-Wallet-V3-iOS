// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit // TODO: replace with MoneyKit
import RIBs
import TransactionKit

final class BuyFlowInteractor: Interactor {

    enum Error: Swift.Error {
        case noCustodialAccountFound(CryptoCurrency)
        case other(Swift.Error)
    }

    var listener: BuyFlowListening?
    weak var router: BuyFlowRouting?

    var paymentMethodsService: TransactionKit.PaymentAccountsServiceAPI = resolve()

    func fetchDefaultAccount(for cryptoCurrency: CryptoCurrency) -> AnyPublisher<CryptoAccount, Error> {
        let asset: CryptoAsset = DIKit.resolve(tag: cryptoCurrency)
        return asset.accountGroup(filter: .custodial)
            .asObservable()
            .asPublisher()
            .mapError(Error.other)
            .flatMap { group -> AnyPublisher<CryptoAccount, Error> in
                guard let account = group.accounts.first as? CryptoAccount else {
                    return .failure(Error.noCustodialAccountFound(cryptoCurrency))
                }
                return .just(account)
            }
            .eraseToAnyPublisher()
    }

    func fetchPaymentAccounts(
        for cryptoCurrency: CryptoCurrency,
        amount: MoneyValue
    ) -> AnyPublisher<[TransactionKit.PaymentAccount], Error> {
        paymentMethodsService.fetchPaymentAccounts(for: cryptoCurrency, amount: amount)
            .mapError(Error.other)
            .eraseToAnyPublisher()
    }
}

extension BuyFlowInteractor: TransactionFlowListener {

    func presentKYCTiersScreen() {
        // TODO: do I even need this?
    }

    func dismissTransactionFlow() {
        // TODO: can I make this also return completed?
        listener?.buyFlowDidComplete(with: .abandoned)
    }
}
