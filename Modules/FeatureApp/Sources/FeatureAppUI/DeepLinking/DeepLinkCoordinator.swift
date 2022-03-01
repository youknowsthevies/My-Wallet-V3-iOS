// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import FeatureActivityUI
import FeatureDashboardUI
import FeatureTransactionUI
import MoneyKit
import PlatformKit
import PlatformUIKit
import UIComponentsKit
import UIKit

public protocol DeepLinkCoordinatorAPI {
    func start()
}

public enum DeepLinkRoutingError: Error {
    case nocrypto
}

final class DeepLinkCoordinator: DeepLinkCoordinatorAPI {

    private let app: AppProtocol
    private let kycRouter: KYCRouting
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let exchangeProvider: ExchangeProviding
    private let transactionRouter: TransactionsRouterAPI
    private let coincore: CoincoreAPI
    private let transactionsRouter: TransactionsRouterAPI

    private var bag: Set<AnyCancellable> = []

    // We can't resolve those at initialization
    private let accountsRouter: () -> AccountsRouting
    private let tabSwapper: () -> TabSwapping

    init(
        app: AppProtocol,
        kycRouter: KYCRouting,
        topMostViewControllerProvider: TopMostViewControllerProviding,
        exchangeProvider: ExchangeProviding,
        transactionRouter: TransactionsRouterAPI,
        coincore: CoincoreAPI,
        transactionsRouter: TransactionsRouterAPI,
        accountsRouter: @escaping () -> AccountsRouting,
        tabSwapper: @escaping () -> TabSwapping
    ) {
        self.app = app
        self.kycRouter = kycRouter
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.exchangeProvider = exchangeProvider
        self.transactionRouter = transactionRouter
        self.coincore = coincore
        self.transactionsRouter = transactionsRouter
        self.accountsRouter = accountsRouter
        self.tabSwapper = tabSwapper
    }

    func start() {

        let observers = [
            activity,
            buy,
            asset,
            qr,
            send,
            kyc
        ]

        for observer in observers {
            observer.store(in: &bag)
        }
    }

    private lazy var activity = app.on(blockchain.app.deep_link.activity)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.showActivity(_:), on: self)

    private lazy var buy = app.on(blockchain.app.deep_link.buy)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.showTransactionBuy(_:), on: self)

    private lazy var send = app.on(blockchain.app.deep_link.send)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.showTransactionSend(_:), on: self)

    private lazy var asset = app.on(blockchain.app.deep_link.asset)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.showAsset(_:), on: self)

    private lazy var qr = app.on(blockchain.app.deep_link.qr)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.qr(_:), on: self)

    private lazy var kyc = app.on(blockchain.app.deep_link.kyc)
        .receive(on: DispatchQueue.main)
        .sink(to: DeepLinkCoordinator.kyc(_:), on: self)

    func kyc(_ event: Session.Event) {
        guard let tierParam = try? event.context.decode(blockchain.app.deep_link.kyc.tier, as: String.self),
              let tierInt = Int(tierParam),
              let tier = KYC.Tier(rawValue: tierInt),
              let topViewController = topMostViewControllerProvider.topMostViewController
        else {
            return
        }

        kycRouter
            .presentEmailVerificationAndKYCIfNeeded(from: topViewController, requiredTier: tier)
            .subscribe()
            .store(in: &bag)
    }

    func qr(_ event: Session.Event) {
        let qrCodeScannerView = QRCodeScannerView()
        topMostViewControllerProvider
            .topMostViewController?
            .present(qrCodeScannerView)
    }

    func showAsset(_ event: Session.Event) {

        let code = (try? event.context.decode(blockchain.app.deep_link.asset.code, as: String.self)) ?? "BTC"
        guard let cryptoCurrency = CryptoCurrency(code: code) else {
            return
        }

        let builder = AssetDetailsBuilder(
            accountsRouter: accountsRouter(),
            currency: cryptoCurrency,
            exchangeProviding: exchangeProvider
        )
        let controller = builder.build()
        topMostViewControllerProvider.topMostViewController?.present(controller, animated: true)
    }

    func showTransactionBuy(_ event: Session.Event) {
        do {
            let code = try event.context.decode(blockchain.app.deep_link.buy.crypto.code, as: String.self)
            guard let cryptoCurrency = CryptoCurrency(code: code) else {
                throw DeepLinkRoutingError.nocrypto
            }
            coincore
                .cryptoAccounts(for: cryptoCurrency)
                .receive(on: DispatchQueue.main)
                .flatMap { [weak self] accounts -> AnyPublisher<TransactionFlowResult, Never> in
                    guard let self = self else {
                        return .just(.abandoned)
                    }
                    return self
                        .transactionRouter
                        .presentTransactionFlow(to: .buy(accounts.first))
                }
                .subscribe()
                .store(in: &bag)
        } catch {
            transactionRouter.presentTransactionFlow(to: .buy(nil))
                .subscribe()
                .store(in: &bag)
        }
    }

    func showTransactionSend(_ event: Session.Event) {
        do {
            let code = try event.context.decode(blockchain.app.deep_link.send.crypto.code, as: String.self)
            guard let cryptoCurrency = CryptoCurrency(code: code) else {
                throw DeepLinkRoutingError.nocrypto
            }
            coincore.cryptoAccounts(for: cryptoCurrency)
                .receive(on: DispatchQueue.main)
                .sink(to: DeepLinkCoordinator.showTransactionSend(with:), on: self)
                .store(in: &bag)
        } catch {
            transactionsRouter.presentTransactionFlow(to: .send(nil, nil))
                .subscribe()
                .store(in: &bag)
        }
    }

    func showTransactionSend(with accounts: [CryptoAccount]) {
        transactionsRouter
            .presentTransactionFlow(to: .send(accounts.first, nil))
            .subscribe()
            .store(in: &bag)
    }

    func showActivity(_ event: Session.Event) {
        tabSwapper().switchToActivity()
    }
}
