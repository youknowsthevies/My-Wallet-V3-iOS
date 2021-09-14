// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Localization
import RxSwift
import ToolKit

public final class CryptoInterestAccount: CryptoAccount, InterestAccount {
    public private(set) lazy var identifier: AnyHashable = "CryptoInterestAccount." + asset.code
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

    public var activity: Single<[ActivityItemEvent]> {
        .just([])
    }

    private let priceService: PriceServiceAPI
    private let balanceService: InterestAccountOverviewAPI
    private var balances: Single<CustodialAccountBalanceState> {
        balanceService.balance(for: asset)
    }

    public init(
        asset: CryptoCurrency,
        priceService: PriceServiceAPI = resolve(),
        balanceService: InterestAccountOverviewAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve()
    ) {
        label = asset.defaultInterestWalletName
        self.asset = asset
        self.balanceService = balanceService
        self.priceService = priceService
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        .just(false)
    }

    public func balancePair(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<MoneyValuePair, Error> {
        priceService
            .price(of: asset, in: fiatCurrency, at: time)
            .eraseError()
            .zip(balance.asPublisher())
            .tryMap { fiatPrice, balance in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice.moneyValue)
            }
            .eraseToAnyPublisher()
    }
}
