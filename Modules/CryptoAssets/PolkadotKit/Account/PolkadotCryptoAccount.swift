// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

final class PolkadotCryptoAccount: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    let id: String
    let label: String
    let asset: CryptoCurrency = .polkadot
    let isDefault: Bool = false

    func createTransactionEngine() -> Any {
        unimplemented()
    }

    var pendingBalance: Single<MoneyValue> {
        unimplemented()
    }

    var balance: Single<MoneyValue> {
        unimplemented()
    }

    var actions: Single<AvailableActions> { .just([]) }

    private let exchangeService: PairExchangeServiceAPI

    init(id: String,
         label: String?,
         exchangeProviding: ExchangeProviding = resolve()) {
        self.id = id
        self.label = label ?? CryptoCurrency.polkadot.defaultWalletName
        self.exchangeService = exchangeProviding[.polkadot]
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        actions.map { $0.contains(action) }
    }

    func balancePair(fiatCurrency: FiatCurrency) -> Observable<MoneyValuePair> {
        exchangeService.fiatPrice
            .flatMapLatest(weak: self) { (self, exchangeRate) in
                self.balance
                    .map { balance -> MoneyValuePair in
                        try MoneyValuePair(base: balance, exchangeRate: exchangeRate.moneyValue)
                    }
                    .asObservable()
            }
    }
}
