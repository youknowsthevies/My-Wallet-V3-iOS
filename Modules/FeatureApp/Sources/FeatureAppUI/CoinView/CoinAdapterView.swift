//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import Combine
import ComposableArchitecture
import DIKit
import FeatureAppDomain
import FeatureCoinData
import FeatureCoinDomain
import FeatureCoinUI
import FeatureDashboardUI
import FeatureInterestUI
import FeatureKYCUI
import FeatureTransactionUI
import MoneyKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

public struct CoinAdapterView: View {

    let app: AppProtocol
    let store: Store<CoinViewState, CoinViewAction>
    let currency: CryptoCurrency
    let analytics: AnalyticsEventRecorderAPI

    public init(
        cryptoCurrency: CryptoCurrency,
        app: AppProtocol = resolve(),
        userAdapter: UserAdapterAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        historicalPriceRepository: HistoricalPriceRepositoryAPI = resolve(),
        ratesRepository: RatesRepositoryAPI = resolve(),
        analytics: AnalyticsEventRecorderAPI = resolve(),
        dismiss: @escaping () -> Void
    ) {
        currency = cryptoCurrency
        self.app = app
        self.analytics = analytics
        store = Store<CoinViewState, CoinViewAction>(
            initialState: .init(
                asset: AssetDetails(cryptoCurrency: cryptoCurrency)
            ),
            reducer: coinViewReducer,
            environment: CoinViewEnvironment(
                app: app,
                kycStatusProvider: { [userAdapter] in
                    userAdapter.userState
                        .compactMap { result -> UserState.KYCStatus? in
                            guard case .success(let userState) = result else {
                                return nil
                            }
                            return userState.kycStatus
                        }
                        .map(FeatureCoinDomain.KYCStatus.init)
                        .eraseToAnyPublisher()
                },
                accountsProvider: { [fiatCurrencyService, coincore] in
                    fiatCurrencyService.displayCurrencyPublisher
                        .setFailureType(to: Error.self)
                        .flatMap { [coincore] fiatCurrency in
                            coincore.cryptoAccounts(for: cryptoCurrency)
                                .map { accounts in
                                    accounts
                                        .filter { !($0 is ExchangeAccount) }
                                        .map { Account($0, fiatCurrency) }
                                }
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                },
                historicalPriceService: HistoricalPriceService(
                    base: cryptoCurrency,
                    displayFiatCurrency: fiatCurrencyService.displayCurrencyPublisher,
                    historicalPriceRepository: historicalPriceRepository
                ),
                interestRatesRepository: ratesRepository,
                explainerService: .init(app: app),
                dismiss: dismiss
            )
        )
    }

    public var body: some View {
        CoinView(store: store)
            .app(app)
            .context([blockchain.ux.asset.id: currency.code])
    }
}

// swiftlint:disable line_length

public final class CoinViewObserver: Session.Observer {

    let app: AppProtocol
    let transactionsRouter: TransactionsRouterAPI
    let coincore: CoincoreAPI
    let kycRouter: KYCAdapter
    let defaults: UserDefaults
    let application: URLOpener
    let topViewController: TopMostViewControllerProviding
    let exchangeProvider: ExchangeProviding
    let accountsRouter: () -> AccountsRouting

    public init(
        app: AppProtocol,
        transactionsRouter: TransactionsRouterAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        kycRouter: KYCAdapter = KYCAdapter(),
        defaults: UserDefaults = .standard,
        application: URLOpener = resolve(),
        topViewController: TopMostViewControllerProviding = resolve(),
        exchangeProvider: ExchangeProviding = resolve(),
        accountsRouter: @escaping () -> AccountsRouting = { resolve() }
    ) {
        self.app = app
        self.transactionsRouter = transactionsRouter
        self.coincore = coincore
        self.kycRouter = kycRouter
        self.defaults = defaults
        self.application = application
        self.topViewController = topViewController
        self.exchangeProvider = exchangeProvider
        self.accountsRouter = accountsRouter
    }

    var observers: [BlockchainEventSubscription] {
        [
            select,
            buy,
            sell,
            receive,
            send,
            swap,
            rewardsWithdraw,
            rewardsDeposit,
            rewardsSummary,
            exchangeWithdraw,
            exchangeDeposit,
            kyc,
            activity,
            website,
            explainerReset
        ]
    }

    public func start() {
        for observer in observers {
            observer.start()
        }
    }

    public func stop() {
        for observer in observers {
            observer.stop()
        }
    }

    lazy var select = app.on(blockchain.ux.asset.select) { @MainActor [unowned self] event in

        let cryptoCurrency = try event.reference.context.decode(blockchain.ux.asset.id) as CryptoCurrency
        let isRedesignEnabled = await app.publisher(for: blockchain.app.configuration.redesign.coinview, as: Bool.self)
            .values.first?.value ?? false

        if isRedesignEnabled {
            let navigationController = UINavigationController()
            navigationController.setViewControllers(
                [
                    UIHostingController(
                        rootView: CoinAdapterView(
                            cryptoCurrency: cryptoCurrency,
                            app: app,
                            dismiss: { [weak navigationController] in
                                navigationController?.dismiss(animated: true)
                            }
                        )
                    )
                ],
                animated: false
            )
            topViewController.topMostViewController?.present(navigationController, animated: true)
        } else {

            let builder = AssetDetailsBuilder(
                accountsRouter: accountsRouter(),
                currency: cryptoCurrency,
                exchangeProviding: exchangeProvider
            )
            let controller = builder.build()
            topViewController.topMostViewController?.present(controller, animated: true)
        }
    }

    lazy var buy = app.on(blockchain.ux.asset.buy, blockchain.ux.asset.account.buy) { [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .buy(cryptoAccount(for: .buy, from: event))
        )
    }

    lazy var sell = app.on(blockchain.ux.asset.sell, blockchain.ux.asset.account.sell) { [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .sell(cryptoAccount(for: .sell, from: event))
        )
    }

    lazy var receive = app.on(blockchain.ux.asset.receive, blockchain.ux.asset.account.receive) { [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .receive(cryptoAccount(for: .receive, from: event))
        )
    }

    lazy var send = app.on(blockchain.ux.asset.send, blockchain.ux.asset.account.send) { [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .send(cryptoAccount(for: .send, from: event), nil)
        )
    }

    lazy var swap = app.on(blockchain.ux.asset.account.swap) { [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .swap(cryptoAccount(for: .swap, from: event))
        )
    }

    lazy var rewardsWithdraw = app.on(blockchain.ux.asset.account.rewards.withdraw) { [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoInterestAccount:
            await transactionsRouter.presentTransactionFlow(to: .interestWithdraw(account))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Withdrawing from rewards requires CryptoInterestAccount")
        }
    }

    lazy var rewardsDeposit = app.on(blockchain.ux.asset.account.rewards.deposit) { [unowned self] event in
        switch try await cryptoAccount(from: event) {
        case let account as CryptoInterestAccount:
            await transactionsRouter.presentTransactionFlow(to: .interestTransfer(account))
        default:
            throw blockchain.ux.asset.account.error[]
                .error(message: "Transferring to rewards requires CryptoInterestAccount")
        }
    }

    lazy var rewardsSummary = app.on(blockchain.ux.asset.account.rewards.summary) { [unowned self] event in
        let account = try await cryptoAccount(from: event)
        let interactor = InterestAccountDetailsScreenInteractor(account: account)
        let presenter = InterestAccountDetailsScreenPresenter(interactor: interactor)
        let controller = await InterestAccountDetailsViewController(presenter: presenter)
        await topViewController.topMostViewController?.present(controller, animated: true, completion: nil)
    }

    lazy var exchangeWithdraw = app.on(blockchain.ux.asset.account.exchange.withdraw) { [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .send(
                cryptoAccount(for: .send, from: event),
                custodialAccount(CryptoTradingAccount.self, from: event)
            )
        )
    }

    lazy var exchangeDeposit = app.on(blockchain.ux.asset.account.exchange.deposit) { [unowned self] event in
        try await transactionsRouter.presentTransactionFlow(
            to: .send(
                custodialAccount(CryptoTradingAccount.self, from: event),
                cryptoAccount(for: .send, from: event)
            )
        )
    }

    lazy var kyc = app.on(blockchain.ux.asset.account.require.KYC) { [unowned self] event in
        let viewController = topViewController.topMostViewController!
        guard
            let result = await kycRouter.presentKYCUpgradeFlow(from: viewController).values.first,
            result != .abandoned
        else {
            return
        }
        if event.reference.context[blockchain.ux.asset.account.id] != nil {
            app.post(
                event: blockchain.ux.asset.account.sheet[].ref(to: event.reference.context)
            )
        } else {
            let account: BlockchainAccount.Type
            typealias AccountType = FeatureCoinDomain.Account.AccountType
            switch try event.context.decode(blockchain.ux.asset.account.type) as AccountType {
            case .trading:
                account = CryptoTradingAccount.self
            case .interest:
                account = CryptoInterestAccount.self
            case .exchange:
                account = CryptoExchangeAccount.self
            case .privateKey:
                return
            }
            try await app.post(
                event: blockchain.ux.asset.account.sheet[].ref(to: event.reference.context + [
                    blockchain.ux.asset.account.id: custodialAccount(account, from: event).identifier
                ])
            )
        }
    }

    lazy var activity = app.on(blockchain.ux.asset.account.activity) { [unowned app] _ in
        app.post(event: blockchain.ux.home.tab[blockchain.ux.user.activity].select)
    }

    lazy var website = app.on(blockchain.ux.asset.bio.visit.website) { [application] event in
        try application.open(event.context.decode(blockchain.ux.asset.bio.visit.website.url, as: URL.self))
    }

    lazy var explainerReset = app.on(blockchain.ux.asset.account.explainer.reset) { [defaults] _ in
        defaults.removeObject(forKey: blockchain.ux.asset.account.explainer(\.id))
    }

    // swiftlint:disable first_where
    func custodialAccount(
        _ type: BlockchainAccount.Type,
        from event: Session.Event
    ) async throws -> CryptoTradingAccount {
        try await coincore.cryptoAccounts(
            for: event.context.decode(blockchain.ux.asset.id),
            filter: .custodial
        )
        .filter(CryptoTradingAccount.self)
        .first
        .or(
            throw: blockchain.ux.asset.error[]
                .error(message: "No trading account found for \(event.reference)")
        )
    }

    func cryptoAccount(
        for action: AssetAction? = nil,
        from event: Session.Event
    ) async throws -> CryptoAccount {
        let accounts = try await coincore.cryptoAccounts(
            for: event.reference.context.decode(blockchain.ux.asset.id),
            supporting: action
        )
        if let id = try? event.reference.context.decode(blockchain.ux.asset.account.id, as: String.self) {
            return try accounts.first(where: { account in account.identifier as? String == id })
                .or(
                    throw: blockchain.ux.asset.error[]
                        .error(message: "No account found with id \(id)")
                )
        } else {
            return try (accounts.first(where: { account in account is TradingAccount }) ?? accounts.first)
                .or(
                    throw: blockchain.ux.asset.error[]
                        .error(message: "\(event) has no valid accounts for \(String(describing: action))")
                )
        }
    }
}

extension FeatureCoinDomain.Account {

    init(_ account: CryptoAccount, _ fiatCurrency: FiatCurrency) {
        self.init(
            id: account.identifier,
            name: account.label,
            accountType: .init(account),
            cryptoCurrency: account.currencyType.cryptoCurrency!,
            fiatCurrency: fiatCurrency,
            actionsPublisher: account.actionsPublisher()
                .map { actions in OrderedSet(actions.compactMap(Account.Action.init)) }
                .eraseToAnyPublisher(),
            cryptoBalancePublisher: account.balancePublisher.ignoreFailure(),
            fiatBalancePublisher: account.fiatBalance(fiatCurrency: fiatCurrency).ignoreFailure()
        )
    }
}

extension FeatureCoinDomain.Account.Action {

    // swiftlint:disable cyclomatic_complexity
    init?(_ action: AssetAction) {
        switch action {
        case .buy:
            self = .buy
        case .deposit:
            self = .exchange.deposit
        case .interestTransfer:
            self = .rewards.deposit
        case .interestWithdraw:
            self = .rewards.withdraw
        case .receive:
            self = .receive
        case .sell:
            self = .sell
        case .send:
            self = .send
        case .sign:
            return nil
        case .swap:
            self = .swap
        case .viewActivity:
            self = .activity
        case .withdraw:
            self = .exchange.withdraw
        }
    }
}

extension FeatureCoinDomain.Account.AccountType {

    init(_ account: CryptoAccount) {
        if account is TradingAccount {
            self = .trading
        } else if account is ExchangeAccount {
            self = .exchange
        } else if account is InterestAccount {
            self = .interest
        } else {
            self = .privateKey
        }
    }
}

extension FeatureCoinDomain.KYCStatus {

    init(_ kycStatus: UserState.KYCStatus) {
        switch kycStatus {
        case .unverified:
            self = .unverified
        case .inReview:
            self = .inReview
        case .silver:
            self = .silver
        case .silverPlus:
            self = .silverPlus
        case .gold:
            self = .gold
        }
    }
}

extension AssetDetails {

    init(cryptoCurrency: CryptoCurrency) {
        self.init(
            name: cryptoCurrency.name,
            code: cryptoCurrency.code,
            brandColor: cryptoCurrency.brandColor,
            about: nil,
            website: nil,
            logoUrl: cryptoCurrency.assetModel.logoPngUrl.flatMap(URL.init(string:)),
            logoImage: cryptoCurrency.assetModel.logoResource.image,
            isTradable: cryptoCurrency.supports(product: .custodialWalletBalance)
                || cryptoCurrency.supports(product: .privateKey)
        )
    }
}

extension TransactionsRouterAPI {

    @discardableResult
    func presentTransactionFlow(to action: TransactionFlowAction) async -> TransactionFlowResult? {
        await presentTransactionFlow(to: action).values.first
    }
}

extension CoincoreAPI {

    func cryptoAccounts(
        for cryptoCurrency: CryptoCurrency,
        supporting action: AssetAction? = nil,
        filter: AssetFilter = .all
    ) async throws -> [CryptoAccount] {
        try await cryptoAccounts(for: cryptoCurrency, supporting: action, filter: filter).values.first ?? []
    }
}
