// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

/// Named `CustodialTradingAccount` on Android
public class CryptoTradingAccount: CryptoAccount, TradingAccount {

    private enum Error: LocalizedError {
        case loadingFailed(asset: String, label: String, action: AssetAction, error: String)

        var errorDescription: String? {
            switch self {
            case let .loadingFailed(asset, label, action, error):
                return "Failed to load: 'CryptoTradingAccount' asset '\(asset)' label '\(label)' action '\(action)' error '\(error)' ."
            }
        }
    }

    private(set) public lazy var identifier: AnyHashable = "CryptoTradingAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false

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
    private let featureFetcher: FeatureFetching
    private let internalFeatureFlagService: InternalFeatureFlagServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let errorRecorder: ErrorRecording
    private let fiatPriceService: FiatPriceServiceAPI

    private var balances: Single<CustodialAccountBalanceState> {
        balanceService.balance(for: asset.currency)
    }

    public init(
        asset: CryptoCurrency,
        errorRecorder: ErrorRecording = resolve(),
        fiatPriceService: FiatPriceServiceAPI = resolve(),
        balanceService: TradingBalanceServiceAPI = resolve(),
        cryptoReceiveAddressFactory: CryptoReceiveAddressFactoryService = resolve(),
        custodialAddressService: CustodialAddressServiceAPI = resolve(),
        custodialPendingDepositService: CustodialPendingDepositServiceAPI = resolve(),
        eligibilityService: EligibilityServiceAPI = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.asset = asset
        self.label = asset.defaultTradingWalletName
        self.fiatPriceService = fiatPriceService
        self.balanceService = balanceService
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
        self.custodialAddressService = custodialAddressService
        self.custodialPendingDepositService = custodialPendingDepositService
        self.eligibilityService = eligibilityService
        self.featureFetcher = featureFetcher
        self.internalFeatureFlagService = internalFeatureFlagService
        self.kycTiersService = kycTiersService
        self.errorRecorder = errorRecorder
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .viewActivity:
            return .just(true)
        case .send:
            guard asset.hasNonCustodialReceiveSupport else {
                return .just(false)
            }
            return balance
                .map(\.isPositive)
                .catchError { [label, asset] error in
                    throw Error.loadingFailed(
                        asset: asset.code,
                        label: label,
                        action: action,
                        error: String(describing: error)
                    )
                }
                .recordErrors(on: errorRecorder)
                .catchErrorJustReturn(false)
        case .buy:
            unimplemented("WIP")
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
                .catchError { [label, asset] error in
                    throw Error.loadingFailed(
                        asset: asset.code,
                        label: label,
                        action: action,
                        error: String(describing: error)
                    )
                }
                .recordErrors(on: errorRecorder)
                .catchErrorJustReturn(false)
        case .receive:
            return Single.just(internalFeatureFlagService.isEnabled(.tradingAccountReceive))
                .flatMap(weak: self) { (self, isEnabled) -> Single<Bool> in
                    guard isEnabled else {
                        return self.featureFetcher.fetchBool(for: .tradingAccountReceive)
                    }
                    return .just(true)
                }
                .catchError { [label, asset] error in
                    throw Error.loadingFailed(
                        asset: asset.code,
                        label: label,
                        action: action,
                        error: String(describing: error)
                    )
                }
                .recordErrors(on: errorRecorder)
                .catchErrorJustReturn(false)
        case .deposit,
             .withdraw:
            return .just(false)
        }
    }

    public func balancePair(fiatCurrency: FiatCurrency) -> Single<MoneyValuePair> {
        Single
            .zip(
                fiatPriceService.getPrice(cryptoCurrency: asset, fiatCurrency: fiatCurrency),
                balance
            )
            .map { (fiatPrice, balance) in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice)
            }
    }

    public func balancePair(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValuePair> {
        Single
            .zip(
                fiatPriceService.getPrice(cryptoCurrency: asset, fiatCurrency: fiatCurrency, date: date),
                balance
            )
            .map { (fiatPrice, balance) in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice)
            }
    }
}
