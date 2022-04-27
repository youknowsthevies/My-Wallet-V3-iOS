// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import RxSwift
import ToolKit

/// Named `CustodialTradingAccount` on Android
public class CryptoTradingAccount: CryptoAccount, TradingAccount {

    private enum CryptoTradingAccountError: LocalizedError {
        case loadingFailed(asset: String, label: String, action: AssetAction, error: String)

        var errorDescription: String? {
            switch self {
            case .loadingFailed(let asset, let label, let action, let error):
                return "Failed to load: 'CryptoTradingAccount' asset '\(asset)' label '\(label)' action '\(action)' error '\(error)' ."
            }
        }
    }

    public private(set) lazy var identifier: AnyHashable = "CryptoTradingAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false
    public var accountType: AccountType = .custodial

    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var receiveAddress: Single<ReceiveAddress> {
        custodialAddressService
            .receiveAddress(for: asset)
            .flatMap(weak: self) { (self, address) in
                self.cryptoReceiveAddressFactory.makeExternalAssetAddress(
                    address: address,
                    label: self.label,
                    onTxCompleted: self.onTxCompleted
                )
                .single
                .map { $0 as ReceiveAddress }
            }
    }

    public var isFunded: Single<Bool> {
        isFundedPublisher.asSingle()
    }

    public var isFundedPublisher: AnyPublisher<Bool, Error> {
        balances
            .map { $0 != .absent }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public var pendingBalance: Single<MoneyValue> {
        balances
            .map(\.balance?.pending)
            .replaceNil(with: .zero(currency: currencyType))
            .asSingle()
    }

    public var balance: Single<MoneyValue> {
        balancePublisher.asSingle()
    }

    public var balancePublisher: AnyPublisher<MoneyValue, Never> {
        balances
            .map(\.balance?.available)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseToAnyPublisher()
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
            .asSingle()
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
            .replaceNil(with: .zero(currency: currencyType))
            .asSingle()
    }

    public var onTxCompleted: (TransactionResult) -> Completable {
        { [weak self] result -> Completable in
            guard let self = self else {
                return .error(PlatformKitError.default)
            }
            guard case .hashed(let hash, let amount) = result else {
                return .error(PlatformKitError.default)
            }
            guard let amount = amount, amount.isCrypto else {
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

    public var disabledReason: AnyPublisher<InterestAccountIneligibilityReason, Error> {
        interestEligibilityRepository
            .fetchInterestAccountEligibilityForCurrencyCode(currencyType)
            .map(\.ineligibilityReason)
            .eraseError()
    }

    public var activity: Single<[ActivityItemEvent]> {
        Single
            .zip(
                buySellActivity.buySellActivityEvents(cryptoCurrency: asset),
                ordersActivity.activity(cryptoCurrency: asset).asSingle().catchAndReturn([]),
                swapActivity.fetchActivity(cryptoCurrency: asset, directions: [.internal])
                    .catchAndReturn([])
            )
            .map { buySellActivity, ordersActivity, swapActivity -> [ActivityItemEvent] in
                let swapAndSellActivityItemsEvents: [ActivityItemEvent] = swapActivity
                    .map { item in
                        if item.pair.outputCurrencyType.isFiatCurrency {
                            return .buySell(.init(swapActivityItemEvent: item))
                        }
                        return .swap(item)
                    }

                return buySellActivity.map(ActivityItemEvent.buySell)
                    + ordersActivity.map(ActivityItemEvent.crypto)
                    + swapAndSellActivityItemsEvents
            }
    }

    private var isInterestWithdrawAndDepositEnabled: AnyPublisher<Bool, Never> {
        featureFlagsService
            .isEnabled(
                .remote(.interestWithdrawAndDeposit)
            )
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private let featureFlagsService: FeatureFlagsServiceAPI
    private let balanceService: TradingBalanceServiceAPI
    private let cryptoReceiveAddressFactory: ExternalAssetAddressFactory
    private let custodialAddressService: CustodialAddressServiceAPI
    private let custodialPendingDepositService: CustodialPendingDepositServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let errorRecorder: ErrorRecording
    private let priceService: PriceServiceAPI
    private let featureFlagService: FeatureFlagsServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let ordersActivity: OrdersActivityServiceAPI
    private let swapActivity: SwapActivityServiceAPI
    private let buySellActivity: BuySellActivityItemEventServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI

    private var balances: AnyPublisher<CustodialAccountBalanceState, Never> {
        balanceService.balance(for: asset.currencyType)
    }

    public init(
        asset: CryptoCurrency,
        swapActivity: SwapActivityServiceAPI = resolve(),
        ordersActivity: OrdersActivityServiceAPI = resolve(),
        buySellActivity: BuySellActivityItemEventServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        featureFlagService: FeatureFlagsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        balanceService: TradingBalanceServiceAPI = resolve(),
        cryptoReceiveAddressFactory: ExternalAssetAddressFactory,
        custodialAddressService: CustodialAddressServiceAPI = resolve(),
        custodialPendingDepositService: CustodialPendingDepositServiceAPI = resolve(),
        eligibilityService: EligibilityServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        interestEligibilityRepository: InterestAccountEligibilityRepositoryAPI = resolve()
    ) {
        self.asset = asset
        label = asset.defaultTradingWalletName
        self.interestEligibilityRepository = interestEligibilityRepository
        self.ordersActivity = ordersActivity
        self.swapActivity = swapActivity
        self.buySellActivity = buySellActivity
        self.priceService = priceService
        self.balanceService = balanceService
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
        self.custodialAddressService = custodialAddressService
        self.custodialPendingDepositService = custodialPendingDepositService
        self.eligibilityService = eligibilityService
        self.featureFlagService = featureFlagService
        self.kycTiersService = kycTiersService
        self.errorRecorder = errorRecorder
        self.supportedPairsInteractorService = supportedPairsInteractorService
        featureFlagsService = featureFlagService
    }

    private var isPairToFiatAvailable: AnyPublisher<Bool, Never> {
        supportedPairsInteractorService
            .pairs
            .asPublisher()
            .prefix(1)
            .map { [asset] pairs in
                pairs.cryptoCurrencySet.contains(asset)
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .viewActivity, .receive:
            return .just(true)
        case .deposit,
             .interestWithdraw,
             .sign,
             .withdraw:
            return .just(false)
        case .send:
            return isFundedPublisher
        case .buy:
            return isPairToFiatAvailable
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .sell:
            return canPerformSell
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .swap:
            return canPerformSwap
        case .interestTransfer:
            return canPerformInterestTransfer
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        priceService
            .price(of: asset, in: fiatCurrency, at: time)
            .eraseError()
            .zip(balancePublisher)
            .tryMap { fiatPrice, balance in
                MoneyValuePair(base: balance, exchangeRate: fiatPrice.moneyValue)
            }
            .eraseToAnyPublisher()
    }

    public func invalidateAccountBalance() {
        balanceService
            .invalidateTradingAccountBalances()
    }

    // MARK: - Private Functions

    private var canPerformSwap: AnyPublisher<Bool, Error> {
        isFundedPublisher
            .flatMap { [eligibilityService] isFunded -> AnyPublisher<Bool, Error> in
                guard isFunded else {
                    return .just(false)
                }
                return eligibilityService.isEligiblePublisher
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private var canPerformSell: AnyPublisher<Bool, Never> {
        isPairToFiatAvailable
            .flatMap { [isFundedPublisher] isPairToFiatAvailable -> AnyPublisher<Bool, Never> in
                guard isPairToFiatAvailable else {
                    return .just(false)
                }
                return isFundedPublisher
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private var canPerformInterestTransfer: AnyPublisher<Bool, Never> {
        Publishers
            .Zip3(
                disabledReason.map(\.isEligible),
                isFundedPublisher,
                isInterestWithdrawAndDepositEnabled.setFailureType(to: Error.self)
            )
            .map { isEligible, isFunded, isInterestWithdrawAndDepositEnabled in
                isEligible && isFunded && isInterestWithdrawAndDepositEnabled
            }
            .mapError { [label, asset] error in
                CryptoTradingAccountError.loadingFailed(
                    asset: asset.code,
                    label: label,
                    action: .interestTransfer,
                    error: String(describing: error)
                )
            }
            .recordErrors(on: errorRecorder)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
