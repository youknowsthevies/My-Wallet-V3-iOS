// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftformat:disable redundantSelf

import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import RxToolKit
import ToolKit

final class StellarCryptoAccount: CryptoNonCustodialAccount {

    private(set) lazy var identifier: AnyHashable = "StellarCryptoAccount.\(publicKey)"
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true

    func createTransactionEngine() -> Any {
        StellarOnChainTransactionEngineFactory()
    }

    var balance: Single<MoneyValue> {
        accountCache.valueSingle
            .map(\.balance)
            .moneyValue
    }

    var actionableBalance: Single<MoneyValue> {
        accountCache.valueSingle
            .map(\.actionableBalance)
            .moneyValue
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: asset))
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(StellarReceiveAddress(address: publicKey, label: label))
    }

    var activity: Single<[ActivityItemEvent]> {
        Single.zip(nonCustodialActivity, swapActivity.asSingle())
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
    }

    private var isInterestTransferAvailable: AnyPublisher<Bool, Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just(false)
        }
        return isInterestWithdrawAndDepositEnabled
            .zip(canPerformInterestTransfer)
            .map { isEnabled, canPerform in
                isEnabled && canPerform
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var isInterestWithdrawAndDepositEnabled: AnyPublisher<Bool, Never> {
        featureFlagsService
            .isEnabled(.interestWithdrawAndDeposit)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var nonCustodialActivity: Single<[TransactionalActivityItemEvent]> {
        operationsService
            .transactions(accountID: publicKey, size: 50)
            .map { response in
                response
                    .map(\.activityItemEvent)
            }
            .catchAndReturn([])
    }

    private var swapActivity: AnyPublisher<[SwapActivityItemEvent], Never> {
        swapTransactionsService
            .fetchActivity(cryptoCurrency: asset, directions: custodialDirections)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private let featureFlagsService: FeatureFlagsServiceAPI
    private let publicKey: String
    private let hdAccountIndex: Int
    private let bridge: StellarWalletBridgeAPI
    private let accountDetailsService: StellarAccountDetailsServiceAPI
    private let priceService: PriceServiceAPI
    private let accountCache: CachedValue<StellarAccountDetails>
    private let operationsService: StellarHistoricalTransactionServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI

    init(
        publicKey: String,
        label: String? = nil,
        hdAccountIndex: Int,
        bridge: StellarWalletBridgeAPI = resolve(),
        operationsService: StellarHistoricalTransactionServiceAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        accountDetailsService: StellarAccountDetailsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        let asset = CryptoCurrency.stellar
        self.asset = asset
        self.bridge = bridge
        self.publicKey = publicKey
        self.hdAccountIndex = hdAccountIndex
        self.label = label ?? asset.defaultWalletName
        self.accountDetailsService = accountDetailsService
        self.swapTransactionsService = swapTransactionsService
        self.operationsService = operationsService
        self.priceService = priceService
        self.featureFlagsService = featureFlagsService
        accountCache = CachedValue(
            configuration: .periodic(
                seconds: 20,
                schedulerIdentifier: "StellarCryptoAccount"
            )
        )
        accountCache.setFetch(weak: self) { (self) -> Single<StellarAccountDetails> in
            self.accountDetailsService.accountDetails(for: publicKey)
        }
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .receive,
             .send,
             .buy,
             .viewActivity:
            return .just(true)
        case .deposit,
             .sign,
             .withdraw,
             .interestWithdraw:
            return .just(false)
        case .interestTransfer:
            return isInterestTransferAvailable
                .flatMap { [isFundedPublisher] isEnabled in
                    isEnabled ? isFundedPublisher : .just(false)
                }
                .eraseToAnyPublisher()
        case .sell, .swap:
            return isFundedPublisher
        }
    }

    func updateLabel(_ newLabel: String) -> Completable {
        bridge.update(accountIndex: hdAccountIndex, label: newLabel)
    }

    func balancePair(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<MoneyValuePair, Error> {
        priceService
            .price(of: asset, in: fiatCurrency, at: time)
            .eraseError()
            .zip(balancePublisher)
            .tryMap { fiatPrice, balance in
                MoneyValuePair(base: balance, exchangeRate: fiatPrice.moneyValue)
            }
            .eraseToAnyPublisher()
    }

    func invalidateAccountBalance() {
        accountCache
            .invalidate()
    }
}
