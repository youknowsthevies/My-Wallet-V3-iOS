// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class EthereumCryptoAccount: CryptoNonCustodialAccount {

    private(set) lazy var identifier: AnyHashable = "EthereumCryptoAccount.\(asset.code).\(publicKey)"
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true
    let publicKey: String
    let network: EVMNetwork

    func createTransactionEngine() -> Any {
        EthereumOnChainTransactionEngineFactory()
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        ethereumBalanceRepository
            .balance(
                network: network,
                for: publicKey
            )
            .asSingle()
            .moneyValue
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: asset))
    }

    var actions: Single<AvailableActions> {
        Single.zip(
            isFunded,
            isInterestTransferAvailable.asSingle()
        )
        .map { [asset] isFunded, isInterestEnabled -> AvailableActions in
            var base: AvailableActions = [.viewActivity, .receive, .send]
            if asset.supports(product: .custodialWalletBalance) {
                base.insert(.buy)
            }
            if isFunded {
                base.insert(.swap)
                base.insert(.sell)
                if isInterestEnabled {
                    base.insert(.interestTransfer)
                }
            }
            return base
        }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(EthereumReceiveAddress(address: publicKey, label: label, onTxCompleted: onTxCompleted)!)
    }

    var activity: Single<[ActivityItemEvent]> {
        Single.zip(nonCustodialActivity, swapActivity)
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
    }

    var nonce: AnyPublisher<BigUInt, EthereumNonceRepositoryError> {
        nonceRepository.nonce(
            network: network,
            for: publicKey
        )
    }

    private var isInterestTransferAvailable: AnyPublisher<Bool, Never> {
        Single.zip(
            canPerformInterestTransfer(),
            isInterestWithdrawAndDepositEnabled
                .asSingle()
        )
        .map { $0.0 && $0.1 }
        .asPublisher()
        .replaceError(with: false)
        .eraseToAnyPublisher()
    }

    private var nonCustodialActivity: Single<[TransactionalActivityItemEvent]> {
        transactionsService
            .transactions(network: network, address: publicKey)
            .map { transactions in
                transactions
                    .map(\.activityItemEvent)
            }
            .replaceError(with: [])
            .asSingle()
    }

    private var swapActivity: Single<[SwapActivityItemEvent]> {
        swapTransactionsService
            .fetchActivity(cryptoCurrency: asset, directions: custodialDirections)
            .catchAndReturn([])
    }

    private var isInterestWithdrawAndDepositEnabled: AnyPublisher<Bool, Never> {
        featureFlagsService
            .isEnabled(
                .remote(.interestWithdrawAndDeposit)
            )
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private let bridge: EthereumWalletBridgeAPI
    private let ethereumBalanceRepository: EthereumBalanceRepositoryAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let hdAccountIndex: Int
    private let nonceRepository: EthereumNonceRepositoryAPI
    private let priceService: PriceServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI
    private let transactionsService: HistoricalTransactionsRepositoryAPI

    init(
        network: EVMNetwork,
        publicKey: String,
        label: String? = nil,
        hdAccountIndex: Int,
        transactionsService: HistoricalTransactionsRepositoryAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        bridge: EthereumWalletBridgeAPI = resolve(),
        ethereumBalanceRepository: EthereumBalanceRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve(),
        nonceRepository: EthereumNonceRepositoryAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        let asset = network.cryptoCurrency
        self.asset = asset
        self.network = network
        self.publicKey = publicKey
        self.hdAccountIndex = hdAccountIndex
        self.priceService = priceService
        self.transactionsService = transactionsService
        self.swapTransactionsService = swapTransactionsService
        self.ethereumBalanceRepository = ethereumBalanceRepository
        self.bridge = bridge
        self.label = label ?? asset.defaultWalletName
        self.featureFlagsService = featureFlagsService
        self.nonceRepository = nonceRepository
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive,
             .send,
             .viewActivity,
             .buy:
            return .just(true)
        case .interestTransfer:
            return isInterestTransferAvailable
                .asSingle()
                .flatMap { [isFunded] isEnabled in
                    isEnabled ? isFunded : .just(false)
                }
        case .deposit,
             .sign,
             .withdraw,
             .interestWithdraw:
            return .just(false)
        case .sell:
            return isFunded
        case .swap:
            return isFunded
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
        ethereumBalanceRepository.invalidateCache()
    }
}
