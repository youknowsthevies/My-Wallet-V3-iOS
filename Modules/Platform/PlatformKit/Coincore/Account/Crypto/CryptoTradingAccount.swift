// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

/// Named `CustodialTradingAccount` on Android
public class CryptoTradingAccount: CryptoAccount, TradingAccount {

    public lazy var id: String = "CryptoTradingAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false
    public let accountType: SingleAccountType = .custodial(.trading)

    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var receiveAddress: Single<ReceiveAddress> {
        custodialAddressService
            .receiveAddress(for: asset)
            .flatMap(weak: self) { (self, address) in
                self.cryptoReceiveAddressFactory.makeExternalAssetAddress(
                    asset: self.asset,
                    address: address,
                    label: self.label,
                    onTxCompleted: self.onTxCompleted
                )
                .single
                .map { $0 as ReceiveAddress }
            }
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
        balances
            .map(\.balance)
            .map { [asset] balance -> (available: MoneyValue, pending: MoneyValue) in
                guard let balance = balance else {
                    return (.zero(currency: asset), .zero(currency: asset))
                }
                return (balance.available, balance.pending)
            }
            .map { [asset] values -> MoneyValue in
                guard values.available.isPositive else {
                    return .zero(currency: asset)
                }
                return try values.available - values.pending
            }
    }

    public var withdrawableBalance: Single<MoneyValue> {
        balances
            .map(\.balance?.withdrawable)
            .onNilJustReturn(.zero(currency: currencyType))
    }

    public var onTxCompleted: (TransactionResult) -> Completable {
        { [weak self] result -> Completable in
            guard let self = self else {
                return .error(PlatformKitError.default)
            }
            guard case let .hashed(hash, amount) = result else {
                return .error(PlatformKitError.default)
            }
            guard amount.isCrypto else {
                return .error(PlatformKitError.default)
            }
            return self.receiveAddress
                .flatMapCompletable(weak: self) { (self, receiveAddress) -> Completable in
                    self.custodialPendingDepositService.createPendingDeposit(
                        value: amount,
                        destination: receiveAddress.address,
                        transactionHash: hash,
                        product: "SIMPLEBUY"
                    )
                }
        }
    }

    public var actions: Single<AvailableActions> {
        Single.zip(balance, eligibilityService.isEligible, can(perform: .receive))
            .map { [asset] (balance, isEligible, canReceive) -> AvailableActions in
                var base: AvailableActions = [.viewActivity]
                if balance.isPositive, asset.hasNonCustodialWithdrawalSupport {
                    base.insert(.send)
                }
                if balance.isPositive && isEligible {
                    base.insert(.sell)
                    base.insert(.swap)
                }
                if canReceive {
                    base.insert(.receive)
                }
                return base
            }
    }

    private let balanceService: TradingBalanceServiceAPI
    private let cryptoReceiveAddressFactory: CryptoReceiveAddressFactoryService
    private let custodialAddressService: CustodialAddressServiceAPI
    private let custodialPendingDepositService: CustodialPendingDepositServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let exchangeService: PairExchangeServiceAPI
    private let featureFetcher: FeatureFetching
    private let internalFeatureFlagService: InternalFeatureFlagServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private var balances: Single<CustodialAccountBalanceState> {
        balanceService.balance(for: asset.currency)
    }

    public init(
        asset: CryptoCurrency,
        balanceService: TradingBalanceServiceAPI = resolve(),
        cryptoReceiveAddressFactory: CryptoReceiveAddressFactoryService = resolve(),
        custodialAddressService: CustodialAddressServiceAPI = resolve(),
        custodialPendingDepositService: CustodialPendingDepositServiceAPI = resolve(),
        eligibilityService: EligibilityServiceAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.asset = asset
        self.label = asset.defaultTradingWalletName
        self.balanceService = balanceService
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
        self.custodialAddressService = custodialAddressService
        self.custodialPendingDepositService = custodialPendingDepositService
        self.eligibilityService = eligibilityService
        self.exchangeService = exchangeProviding[asset]
        self.featureFetcher = featureFetcher
        self.internalFeatureFlagService = internalFeatureFlagService
        self.kycTiersService = kycTiersService
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .viewActivity:
            return .just(true)
        case .send:
            return balance
                .map(\.isPositive)
                .map { [asset] isPositive in
                    isPositive && asset.hasNonCustodialWithdrawalSupport
                }
        case .sell,
             .swap:
            return balance
                .map(\.isPositive)
                .flatMap(weak: self) { (self, isPositive) -> Single<Bool> in
                    guard isPositive else {
                        return .just(false)
                    }
                    return self.eligibilityService.isEligible
                }
        case .receive:
            return Single.just(internalFeatureFlagService.isEnabled(.tradingAccountReceive))
                .flatMap(weak: self) { (self, isEnabled) -> Single<Bool> in
                    guard isEnabled else {
                        return self.featureFetcher.fetchBool(for: .tradingAccountReceive)
                    }
                    return .just(true)
                }
        case .deposit,
             .withdraw:
            return .just(false)
        }
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
