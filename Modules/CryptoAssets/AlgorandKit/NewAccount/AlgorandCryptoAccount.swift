// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

final class AlgorandCryptoAccount: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    let id: String
    let label: String
    let asset: CryptoCurrency = .algorand
    let isDefault: Bool = false

    func createTransactionEngine() -> Any {
        unimplemented()
    }

    var pendingBalance: Single<MoneyValue> {
        unimplemented()
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        unimplemented()
    }

    var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    var actions: Single<AvailableActions> { .just([]) }

    private let exchangeService: PairExchangeServiceAPI

    init(id: String,
         label: String?,
         exchangeProviding: ExchangeProviding = resolve()) {
        self.id = id
        self.label = label ?? CryptoCurrency.algorand.defaultWalletName
        self.exchangeService = exchangeProviding[.algorand]
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
