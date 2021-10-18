// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20CryptoAccount: CryptoNonCustodialAccount {
    private(set) lazy var identifier: AnyHashable = "ERC20CryptoAccount.\(asset.code).\(publicKey)"
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true

    func createTransactionEngine() -> Any {
        ERC20OnChainTransactionEngineFactory(erc20Token: erc20Token)
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balance(for: EthereumAddress(address: publicKey)!, cryptoCurrency: asset)
            .asSingle()
            .moneyValue
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: asset))
    }

    var actions: Single<AvailableActions> {
        Single.zip(
            isFunded,
            isPairToFiatAvailable,
            hasHistory.asSingle(),
            canPerformInterestTransfer(),
            featureFlagsService
                .isEnabled(.remote(.sellUsingTransactionFlowEnabled)).asSingle()
        )
        .map { isFunded, isPairToFiatAvailable, hasHistory, isInterestEnabled, isSellEnabled -> AvailableActions in
            var base: AvailableActions = [.receive]
            if hasHistory || isFunded {
                base.insert(.viewActivity)
            }
            if isPairToFiatAvailable {
                base.insert(.buy)
            }
            if isFunded {
                base.formUnion([.send, .swap])
            }
            if isFunded, isSellEnabled {
                base.insert(.sell)
            }
            if isFunded, isInterestEnabled {
                base.insert(.interestTransfer)
            }
            return base
        }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(ERC20ReceiveAddress(asset: asset, address: publicKey, label: label, onTxCompleted: onTxCompleted))
    }

    var activity: Single<[ActivityItemEvent]> {
        Single.zip(nonCustodialActivity, swapActivity)
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
    }

    private var nonCustodialActivity: Single<[TransactionalActivityItemEvent]> {
        transactionsService
            .transactions(erc20Asset: erc20Token, address: EthereumAddress(address: publicKey)!)
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

    /// Stream a boolean indicating if this ERC20 token has ever been transacted,
    private var hasHistory: AnyPublisher<Bool, Never> {
        erc20TokenAccountsRepository
            .tokens(for: EthereumAddress(address: publicKey)!)
            .map { [erc20Token] tokens in
                tokens[erc20Token.cryptoCurrency] != nil
            }
            .replaceError(with: false)
            .ignoreFailure()
    }

    private let publicKey: String
    private let erc20Token: ERC20AssetModel
    private let erc20TokenAccountsRepository: ERC20TokenAccountsRepositoryAPI
    private let balanceService: ERC20BalanceServiceAPI
    private let featureFetcher: FeatureFetching
    private let priceService: PriceServiceAPI
    private let transactionsService: ERC20HistoricalTransactionServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let featureFlagsService: FeatureFlagsServiceAPI

    init(
        publicKey: String,
        erc20Token: ERC20AssetModel,
        erc20TokenAccountsRepository: ERC20TokenAccountsRepositoryAPI = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        balanceService: ERC20BalanceServiceAPI = resolve(),
        transactionsService: ERC20HistoricalTransactionServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        self.publicKey = publicKey
        self.erc20Token = erc20Token
        asset = erc20Token.cryptoCurrency
        label = erc20Token.cryptoCurrency.defaultWalletName
        self.balanceService = balanceService
        self.featureFetcher = featureFetcher
        self.transactionsService = transactionsService
        self.swapTransactionsService = swapTransactionsService
        self.priceService = priceService
        self.supportedPairsInteractorService = supportedPairsInteractorService
        self.featureFlagsService = featureFlagsService
        self.erc20TokenAccountsRepository = erc20TokenAccountsRepository
    }

    private var isPairToFiatAvailable: Single<Bool> {
        supportedPairsInteractorService
            .pairs
            .take(1)
            .asSingle()
            .map { [asset] pairs in
                pairs.cryptoCurrencySet.contains(asset)
            }
            .catchErrorJustReturn(false)
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive:
            return .just(true)
        case .interestTransfer:
            return canPerformInterestTransfer()
                .flatMap { [isFunded] isEnabled in
                    isEnabled ? isFunded : .just(false)
                }
        case .deposit,
             .withdraw,
             .interestWithdraw:
            return .just(false)
        case .viewActivity:
            return hasHistory.asSingle()
        case .send,
             .swap:
            return isFunded
        case .buy:
            return isPairToFiatAvailable
        case .sell:
            return featureFlagsService
                .isEnabled(.remote(.sellUsingTransactionFlowEnabled))
                .asSingle()
                .flatMap(weak: self) { (self, _) in
                    Single.zip(self.isPairToFiatAvailable, self.isFunded).map {
                        $0.0 && $0.1
                    }
                }
        }
    }

    func balancePair(fiatCurrency: FiatCurrency, at time: PriceTime) -> AnyPublisher<MoneyValuePair, Error> {
        priceService
            .price(of: asset, in: fiatCurrency, at: time)
            .eraseError()
            .zip(balance.asPublisher())
            .tryMap { fiatPrice, balance in
                MoneyValuePair(base: balance, exchangeRate: fiatPrice.moneyValue)
            }
            .eraseToAnyPublisher()
    }
}
