// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import RxSwift
import ToolKit

public final class CryptoInterestAccount: CryptoAccount {
    public lazy var id: String = "CryptoInterestAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false

    public var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }
    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var isFunded: Single<Bool> {
        balances.map { $0 != .absent }
    }

    public var pendingBalance: Single<MoneyValue> {
        balances
            .map(\.balance?.pending)
            .onNilJustReturn(.zero(currency: currencyType))
    }

    public var balance: Single<MoneyValue> {
        balances
            .map(\.balance?.available)
            .onNilJustReturn(.zero(currency: currencyType))
    }

    public var actionableBalance: Single<MoneyValue> {
        balance
    }

    public var actions: Single<AvailableActions> {
        .just([])
    }

    private let balanceService: SavingsOverviewAPI
    private let exchangeService: PairExchangeServiceAPI
    private var balances: Single<CustodialAccountBalanceState> {
        balanceService.balance(for: asset)
    }

    public init(asset: CryptoCurrency,
                balanceService: SavingsOverviewAPI = resolve(),
                exchangeProviding: ExchangeProviding = resolve()) {
        self.label = asset.defaultInterestWalletName
        self.asset = asset
        self.exchangeService = exchangeProviding[asset]
        self.balanceService = balanceService
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        .just(false)
    }

    public func balancePair(fiatCurrency: FiatCurrency) -> Observable<MoneyValuePair> {
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
