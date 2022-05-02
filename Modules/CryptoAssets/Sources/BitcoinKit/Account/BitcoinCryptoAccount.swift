// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import Localization
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class BitcoinCryptoAccount: BitcoinChainCryptoAccount {

    private(set) lazy var identifier: AnyHashable = "BitcoinCryptoAccount.\(xPub.address).\(xPub.derivationType)"
    let label: String
    let asset: CryptoCurrency = .bitcoin
    let isDefault: Bool
    let hdAccountIndex: Int

    func createTransactionEngine() -> Any {
        BitcoinOnChainTransactionEngineFactory<BitcoinToken>()
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: .bitcoin))
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balances(for: walletAccount.publicKeys.xpubs)
            .asSingle()
            .moneyValue
    }

    var receiveAddress: Single<ReceiveAddress> {
        bridge.receiveAddress(forXPub: xPub.address)
            .map { [label, onTxCompleted] address -> ReceiveAddress in
                BitcoinChainReceiveAddress<BitcoinToken>(
                    address: address,
                    label: label,
                    onTxCompleted: onTxCompleted
                )
            }
    }

    var firstReceiveAddress: Single<ReceiveAddress> {
        bridge.firstReceiveAddress(forXPub: xPub.address)
            .map { [label, onTxCompleted] address -> ReceiveAddress in
                BitcoinChainReceiveAddress<BitcoinToken>(
                    address: address,
                    label: label,
                    onTxCompleted: onTxCompleted
                )
            }
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
        transactionsService
            .transactions(publicKeys: walletAccount.publicKeys.xpubs)
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
    private let xPub: XPub
    private let balanceService: BalanceServiceAPI
    private let bridge: BitcoinWalletBridgeAPI
    private let priceService: PriceServiceAPI
    private let walletAccount: BitcoinWalletAccount
    private let transactionsService: BitcoinHistoricalTransactionServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI

    init(
        walletAccount: BitcoinWalletAccount,
        isDefault: Bool,
        balanceService: BalanceServiceAPI = resolve(tag: BitcoinChainKit.BitcoinChainCoin.bitcoin),
        transactionsService: BitcoinHistoricalTransactionServiceAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        bridge: BitcoinWalletBridgeAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        xPub = walletAccount.publicKeys.default
        hdAccountIndex = walletAccount.index
        label = walletAccount.label ?? CryptoCurrency.bitcoin.defaultWalletName
        self.isDefault = isDefault
        self.balanceService = balanceService
        self.priceService = priceService
        self.transactionsService = transactionsService
        self.swapTransactionsService = swapTransactionsService
        self.bridge = bridge
        self.walletAccount = walletAccount
        self.featureFlagsService = featureFlagsService
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

    func updateLabel(_ newLabel: String) -> Completable {
        bridge.update(accountIndex: hdAccountIndex, label: newLabel)
    }

    func invalidateAccountBalance() {
        balanceService
            .invalidateBalanceForWallet(xPub)
    }
}
