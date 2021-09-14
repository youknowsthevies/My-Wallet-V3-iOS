// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

class BitcoinCryptoAccount: CryptoNonCustodialAccount {

    private(set) lazy var identifier: AnyHashable = "BitcoinCryptoAccount.\(xPub.address).\(xPub.derivationType)"
    let label: String
    let asset: CryptoCurrency = .coin(.bitcoin)
    let isDefault: Bool

    func createTransactionEngine() -> Any {
        BitcoinOnChainTransactionEngineFactory<BitcoinToken>()
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: .coin(.bitcoin)))
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balances(for: walletAccount.publicKeys.xpubs)
            .moneyValue
    }

    var actions: Single<AvailableActions> {
        isFunded
            .map { isFunded -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive, .send, .buy]
                if isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        bridge.receiveAddress(forXPub: xPub.address)
            .flatMap { [bridge] address -> Single<(Int32, String)> in
                Single.zip(bridge.walletIndex(for: address), .just(address))
            }
            .map { [label, onTxCompleted] index, address -> ReceiveAddress in
                BitcoinChainReceiveAddress<BitcoinToken>(
                    address: address,
                    label: label,
                    onTxCompleted: onTxCompleted,
                    index: index
                )
            }
    }

    var activity: Single<[ActivityItemEvent]> {
        Single.zip(nonCustodialActivity, swapActivity)
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
    }

    private var nonCustodialActivity: Single<[TransactionalActivityItemEvent]> {
        transactionsService
            .transactions(publicKeys: walletAccount.publicKeys.xpubs)
            .map { response in
                response
                    .map(\.activityItemEvent)
            }
            .catchErrorJustReturn([])
    }

    private var swapActivity: Single<[SwapActivityItemEvent]> {
        swapTransactionsService
            .fetchActivity(cryptoCurrency: asset, directions: custodialDirections)
            .catchErrorJustReturn([])
    }

    private let xPub: XPub
    private let balanceService: BalanceServiceAPI
    private let bridge: BitcoinWalletBridgeAPI
    private let hdAccountIndex: Int
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
        bridge: BitcoinWalletBridgeAPI = resolve()
    ) {
        xPub = walletAccount.publicKeys.default
        hdAccountIndex = walletAccount.index
        label = walletAccount.label ?? CryptoCurrency.coin(.bitcoin).defaultWalletName
        self.isDefault = isDefault
        self.balanceService = balanceService
        self.priceService = priceService
        self.transactionsService = transactionsService
        self.swapTransactionsService = swapTransactionsService
        self.bridge = bridge
        self.walletAccount = walletAccount
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive,
             .send,
             .buy,
             .viewActivity:
            return .just(true)
        case .deposit,
             .withdraw,
             .sell:
            return .just(false)
        case .swap:
            return isFunded
        }
    }

    func balancePair(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<MoneyValuePair, Error> {
        priceService
            .price(of: asset, in: fiatCurrency, at: time)
            .eraseError()
            .zip(balance.asPublisher())
            .tryMap { fiatPrice, balance in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice.moneyValue)
            }
            .eraseToAnyPublisher()
    }

    func updateLabel(_ newLabel: String) -> Completable {
        bridge.update(accountIndex: hdAccountIndex, label: newLabel)
    }
}
