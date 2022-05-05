// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import EthereumKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20CryptoAccount: CryptoNonCustodialAccount {
    private(set) lazy var identifier: AnyHashable = "ERC20CryptoAccount.\(asset.code).\(publicKey)"
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true
    let network: EVMNetwork
    let publicKey: String

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

    var receiveAddress: Single<ReceiveAddress> {
        .just(erc20ReceiveAddress)
    }

    var receiveAddressPublisher: AnyPublisher<ReceiveAddress, Error> {
        .just(erc20ReceiveAddress)
    }

    var activity: Single<[ActivityItemEvent]> {
        Single.zip(nonCustodialActivity, swapActivity)
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
    }

    /// The nonce (transaction count) of this account.
    var nonce: AnyPublisher<BigUInt, EthereumNonceRepositoryError> {
        nonceRepository.nonce(
            network: network,
            for: publicKey
        )
    }

    /// The ethereum balance of this account.
    var ethereumBalance: AnyPublisher<CryptoValue, EthereumBalanceRepositoryError> {
        ethereumBalanceRepository.balance(
            network: network,
            for: publicKey
        )
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
            .isEnabled(
                .remote(.interestWithdrawAndDeposit)
            )
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var nonCustodialActivity: Single<[TransactionalActivityItemEvent]> {
        transactionsService
            .transactions(erc20Asset: erc20Token, address: EthereumAddress(address: publicKey)!)
            .map { response in
                response
                    .map(\.activityItemEvent)
            }
            .catchAndReturn([])
    }

    private var swapActivity: Single<[SwapActivityItemEvent]> {
        swapTransactionsService
            .fetchActivity(cryptoCurrency: asset, directions: custodialDirections)
            .catchAndReturn([])
    }

    /// Stream a boolean indicating if this ERC20 token has ever been transacted,
    private var hasHistory: AnyPublisher<Bool, Never> {
        erc20TokenAccountsRepository
            .tokens(for: EthereumAddress(address: publicKey)!)
            .map { [asset] tokens in
                tokens[asset] != nil
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var erc20ReceiveAddress: ERC20ReceiveAddress {
        ERC20ReceiveAddress(
            asset: asset,
            address: publicKey,
            label: label,
            onTxCompleted: onTxCompleted
        )!
    }

    private let balanceService: ERC20BalanceServiceAPI
    private let erc20Token: AssetModel
    private let erc20TokenAccountsRepository: ERC20TokenAccountsRepositoryAPI
    private let ethereumBalanceRepository: EthereumBalanceRepositoryAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let nonceRepository: EthereumNonceRepositoryAPI
    private let priceService: PriceServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI
    private let transactionsService: ERC20HistoricalTransactionServiceAPI
    private let tradingPairsService: TradingPairsServiceAPI

    init(
        publicKey: String,
        erc20Token: AssetModel,
        balanceService: ERC20BalanceServiceAPI = resolve(),
        erc20TokenAccountsRepository: ERC20TokenAccountsRepositoryAPI = resolve(),
        ethereumBalanceRepository: EthereumBalanceRepositoryAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        nonceRepository: EthereumNonceRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        tradingPairsService: TradingPairsServiceAPI = resolve(),
        transactionsService: ERC20HistoricalTransactionServiceAPI = resolve()
    ) {
        precondition(erc20Token.kind.isERC20)
        self.publicKey = publicKey
        self.erc20Token = erc20Token
        asset = erc20Token.cryptoCurrency!
        network = erc20Token.evmNetwork!
        label = asset.defaultWalletName
        self.balanceService = balanceService
        self.erc20TokenAccountsRepository = erc20TokenAccountsRepository
        self.ethereumBalanceRepository = ethereumBalanceRepository
        self.featureFlagsService = featureFlagsService
        self.nonceRepository = nonceRepository
        self.priceService = priceService
        self.supportedPairsInteractorService = supportedPairsInteractorService
        self.swapTransactionsService = swapTransactionsService
        self.tradingPairsService = tradingPairsService
        self.transactionsService = transactionsService
    }

    private var isPairToFiatAvailable: AnyPublisher<Bool, Never> {
        guard asset.supports(product: .custodialWalletBalance) else {
            return .just(false)
        }
        return supportedPairsInteractorService
            .pairs
            .asPublisher()
            .prefix(1)
            .map { [asset] pairs in
                pairs.cryptoCurrencySet.contains(asset)
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var isPairToCryptoAvailable: AnyPublisher<Bool, Never> {
        tradingPairsService
            .tradingPairs
            .map { [asset] tradingPairs in
                tradingPairs.contains { pair in
                    pair.sourceCurrencyType == asset
                }
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .receive:
            return .just(true)
        case .interestTransfer:
            return isInterestTransferAvailable
                .flatMap { [isFundedPublisher] isEnabled in
                    isEnabled ? isFundedPublisher : .just(false)
                }
                .eraseToAnyPublisher()
        case .deposit,
             .sign,
             .withdraw,
             .interestWithdraw:
            return .just(false)
        case .viewActivity:
            return hasHistory
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .send:
            return isFundedPublisher
        case .swap:
            return isPairToCryptoAvailable
                .flatMap { [isFundedPublisher] isPairToCryptoAvailable -> AnyPublisher<Bool, Never> in
                    guard isPairToCryptoAvailable else {
                        return .just(false)
                    }
                    return isFundedPublisher
                        .replaceError(with: false)
                        .eraseToAnyPublisher()
                }
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .buy:
            return isPairToFiatAvailable
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .sell:
            return isPairToFiatAvailable
                .flatMap { [isFundedPublisher] isPairToFiatAvailable -> AnyPublisher<Bool, Never> in
                    guard isPairToFiatAvailable else {
                        return .just(false)
                    }
                    return isFundedPublisher
                        .replaceError(with: false)
                        .eraseToAnyPublisher()
                }
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
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

    func invalidateAccountBalance() {
        erc20TokenAccountsRepository.invalidateERC20TokenAccountsForAddress(
            EthereumAddress(address: publicKey)!
        )
    }
}
