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
        switch asset {
        case .erc20(let model) where NewERC20Code.allCases.map(\.rawValue).contains(model.code):
            return actionsNewCustodialAsset
        case .other(let model) where NewCustodialCode.allCases.map(\.rawValue).contains(model.code):
            return actionsNewCustodialAsset
        default:
            return actionsLegacyAsset
        }
    }

    public var activity: Single<[ActivityItemEvent]> {
        Single
            .zip(
                buySellActivity.buySellActivityEvents(cryptoCurrency: asset),
                ordersActivity.activity(cryptoCurrency: asset).catchErrorJustReturn([]),
                swapActivity.fetchActivity(cryptoCurrency: asset, directions: [.internal]).catchErrorJustReturn([])
            )
            .map { (buySellActivity, ordersActivity, swapActivity) -> [ActivityItemEvent] in
                buySellActivity.map(ActivityItemEvent.buySell)
                    + ordersActivity.map(ActivityItemEvent.crypto)
                    + swapActivity.map(ActivityItemEvent.swap)
            }

    }

    public var actionsLegacyAsset: Single<AvailableActions> {
        Single.zip(balance, eligibilityService.isEligible)
            .map { (balance, isEligible) -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .buy]
                if balance.isPositive {
                    base.insert(.send)
                }
                if balance.isPositive, isEligible {
                    base.insert(.sell)
                    base.insert(.swap)
                }
                base.insert(.receive)
                return base
            }
    }

    private var actionsNewCustodialAsset: Single<AvailableActions> {
        Single.zip(balance, eligibilityService.isEligible, custodialSupport)
            .map { [asset] (balance, isEligible, custodialSupport) -> AvailableActions in
                let canBuy = custodialSupport.data[asset.code]?.canBuy ?? false
                let canSend = custodialSupport.data[asset.code]?.canSend ?? false
                let canSell = custodialSupport.data[asset.code]?.canSell ?? false
                let canSwap = custodialSupport.data[asset.code]?.canSwap ?? false
                let canReceive = custodialSupport.data[asset.code]?.canReceive ?? false
                var base: AvailableActions = [.viewActivity]
                if balance.isPositive, canSend {
                    base.insert(.send)
                }
                if balance.isPositive, isEligible, canSell {
                    base.insert(.sell)
                }
                if balance.isPositive, isEligible, canSwap {
                    base.insert(.swap)
                }
                if canReceive {
                    base.insert(.receive)
                }
                if canBuy {
                    base.insert(.buy)
                }
                return base
            }
    }

    private let balanceService: TradingBalanceServiceAPI
    private let cryptoReceiveAddressFactory: CryptoReceiveAddressFactoryService
    private let custodialAddressService: CustodialAddressServiceAPI
    private let custodialPendingDepositService: CustodialPendingDepositServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let errorRecorder: ErrorRecording
    private let fiatPriceService: FiatPriceServiceAPI
    private let featureFetcher: FeatureFetching
    private let kycTiersService: KYCTiersServiceAPI
    private let ordersActivity: OrdersActivityServiceAPI
    private let swapActivity: SwapActivityServiceAPI
    private let buySellActivity: BuySellActivityItemEventServiceAPI

    private var balances: Single<CustodialAccountBalanceState> {
        balanceService.balance(for: asset.currency)
    }

    public init(
        asset: CryptoCurrency,
        swapActivity: SwapActivityServiceAPI = resolve(),
        ordersActivity: OrdersActivityServiceAPI = resolve(),
        buySellActivity: BuySellActivityItemEventServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        fiatPriceService: FiatPriceServiceAPI = resolve(),
        balanceService: TradingBalanceServiceAPI = resolve(),
        cryptoReceiveAddressFactory: CryptoReceiveAddressFactoryService = resolve(),
        custodialAddressService: CustodialAddressServiceAPI = resolve(),
        custodialPendingDepositService: CustodialPendingDepositServiceAPI = resolve(),
        eligibilityService: EligibilityServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.asset = asset
        self.label = asset.defaultTradingWalletName
        self.ordersActivity = ordersActivity
        self.swapActivity = swapActivity
        self.buySellActivity = buySellActivity
        self.fiatPriceService = fiatPriceService
        self.balanceService = balanceService
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
        self.custodialAddressService = custodialAddressService
        self.custodialPendingDepositService = custodialPendingDepositService
        self.eligibilityService = eligibilityService
        self.featureFetcher = featureFetcher
        self.kycTiersService = kycTiersService
        self.errorRecorder = errorRecorder
    }

    private var custodialSupport: Single<CryptoCustodialSupport> {
        featureFetcher
            .fetch(for: .custodialOnlyTokens)
            .map { (data: [String: [String]]) in
                CryptoCustodialSupport(data: data)
            }
            .catchErrorJustReturn(.empty)
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        switch asset {
        case .erc20(let model) where NewERC20Code.allCases.map(\.rawValue).contains(model.code):
            return canNewCustodialAsset(perform: action)
                .flatMap(weak: self) { (self, canDoAction) in
                    guard canDoAction else {
                        return .just(false)
                    }
                    return self.canLegacyAsset(perform: action)
                }
        case .other(let model) where NewCustodialCode.allCases.map(\.rawValue).contains(model.code):
            return canNewCustodialAsset(perform: action)
                .flatMap(weak: self) { (self, canDoAction) in
                    guard canDoAction else {
                        return .just(false)
                    }
                    return self.canLegacyAsset(perform: action)
                }
        default:
            return canLegacyAsset(perform: action)
        }
    }

    private func canNewCustodialAsset(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .viewActivity:
            return .just(true)
        case .send:
            return custodialSupport
                .map { [asset] support in
                    support.data[asset.code]?.canSend ?? false
                }
        case .buy:
            return custodialSupport
                .map { [asset] support in
                    support.data[asset.code]?.canBuy ?? false
                }
        case .sell:
            return custodialSupport
                .map { [asset] support in
                    support.data[asset.code]?.canSell ?? false
                }
        case .swap:
            return custodialSupport
                .map { [asset] support in
                    support.data[asset.code]?.canSwap ?? false
                }
        case .receive:
            return custodialSupport
                .map { [asset] support in
                    support.data[asset.code]?.canReceive ?? false
                }
        case .deposit,
             .withdraw:
            return .just(false)
        }
    }

    private func canLegacyAsset(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .viewActivity:
            return .just(true)
        case .send:
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
            return .just(true)
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
            return .just(true)
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
