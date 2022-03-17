//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import Combine
import ComposableArchitecture
import DIKit
import FeatureCoinData
import FeatureCoinDomain
import FeatureCoinUI
import FeatureInterestUI
import FeatureKYCUI
import FeatureTransactionUI
import MoneyKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

struct CoinAdapterView: View {

    let app: AppProtocol
    let store: Store<CoinViewState, CoinViewAction>
    let currency: CryptoCurrency
    let analytics: AnalyticsEventRecorderAPI

    init(
        cryptoCurrency: CryptoCurrency,
        app: AppProtocol = resolve(),
        userAdapter: UserAdapterAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        historicalPriceRepository: HistoricalPriceRepositoryAPI = resolve(),
        ratesRepository: RatesRepositoryAPI = resolve(),
        analytics: AnalyticsEventRecorderAPI = resolve()
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
                explainerService: .init(app: app)
            )
        )
    }

    var body: some View {
        CoinView(store: store)
            .context([blockchain.ux.asset.id: currency.code])
    }
}

struct CoinViewObserver: AppSessionObserver {

    @Environment(\.openURL) var openURL

    var transactionsRouter: TransactionsRouterAPI = resolve()
    var coincore: CoincoreAPI = resolve()
    var kycRouter: FeatureKYCUI.Routing = resolve()
    var defaults: UserDefaults = .standard

    func body(content: Content) -> some View {
        content
            .on(blockchain.ux.asset.buy, blockchain.ux.asset.account.buy) { event in
                try await transactionsRouter.presentTransactionFlow(
                    to: .buy(cryptoAccount(for: .buy, from: event))
                )
            }
            .on(blockchain.ux.asset.sell, blockchain.ux.asset.account.sell) { event in
                try await transactionsRouter.presentTransactionFlow(
                    to: .sell(cryptoAccount(for: .sell, from: event))
                )
            }
            .on(blockchain.ux.asset.receive, blockchain.ux.asset.account.receive) { event in
                try await transactionsRouter.presentTransactionFlow(
                    to: .receive(cryptoAccount(for: .receive, from: event))
                )
            }
            .on(blockchain.ux.asset.send, blockchain.ux.asset.account.send) { event in
                try await transactionsRouter.presentTransactionFlow(
                    to: .send(cryptoAccount(for: .send, from: event), nil)
                )
            }
            .on(blockchain.ux.asset.account.swap) { event in
                try await transactionsRouter.presentTransactionFlow(
                    to: .swap(cryptoAccount(for: .swap, from: event))
                )
            }
            .on(blockchain.ux.asset.account.rewards.withdraw) { event in
                switch try await cryptoAccount(from: event) {
                case let account as CryptoInterestAccount:
                    await transactionsRouter.presentTransactionFlow(to: .interestWithdraw(account))
                default:
                    throw blockchain.ux.asset.account.error[]
                        .error(message: "Withdrawing from rewards requires CryptoInterestAccount")
                }
            }
            .on(blockchain.ux.asset.account.rewards.deposit) { event in
                switch try await cryptoAccount(from: event) {
                case let account as CryptoInterestAccount:
                    await transactionsRouter.presentTransactionFlow(to: .interestTransfer(account))
                default:
                    throw blockchain.ux.asset.account.error[]
                        .error(message: "Transferring to rewards requires CryptoInterestAccount")
                }
            }
            .on(blockchain.ux.asset.account.rewards.summary) { event in
                let account = try await cryptoAccount(from: event)
                let interactor = InterestAccountDetailsScreenInteractor(account: account)
                let presenter = InterestAccountDetailsScreenPresenter(interactor: interactor)
                let controller = InterestAccountDetailsViewController(presenter: presenter)
                let navigationRouter: NavigationRouterAPI = resolve()
                navigationRouter.present(viewController: controller, using: .modalOverTopMost)
            }
            .on(blockchain.ux.asset.account.exchange.withdraw) { event in
                try await transactionsRouter.presentTransactionFlow(
                    to: .send(cryptoAccount(for: .send, from: event), tradingAccount(from: event))
                )
            }
            .on(blockchain.ux.asset.account.exchange.deposit) { event in
                try await transactionsRouter.presentTransactionFlow(
                    to: .send(tradingAccount(from: event), cryptoAccount(for: .send, from: event))
                )
            }
            .on(blockchain.ux.asset.account.require.KYC) { _ in
                let topViewController = (resolve() as TopMostViewControllerProviding).topMostViewController!
                _ = try await kycRouter.presentKYCIfNeeded(from: topViewController, requiredTier: .tier2).values.first
            }
            .on(blockchain.ux.asset.account.activity) { _ in
                app.post(
                    event: blockchain.ux.home.tab.select[]
                        .ref(to: [blockchain.ux.home.tab.id: blockchain.ux.user.activity[]])
                )
            }
            .on(blockchain.ux.asset.bio.visit.website) { event in
                try openURL(event.context.decode(blockchain.ux.asset.bio.visit.website.url, as: URL.self))
            }
            .on(blockchain.ux.asset.account.explainer.reset) { _ in
                defaults.removeObject(forKey: blockchain.ux.asset.account.explainer(\.id))
            }
    }

    // swiftlint:disable first_where
    func tradingAccount(from event: Session.Event) async throws -> CryptoTradingAccount {
        try await coincore.cryptoAccounts(
            for: event.context.decode(blockchain.ux.asset.id),
            filter: .custodial
        )
        .filter(CryptoTradingAccount.self)
        .first
        .or(
            throw: blockchain.ux.asset.error[]
                .error(message: "No trading account found for \(event.ref)")
        )
    }

    func cryptoAccount(
        for action: AssetAction? = nil,
        from event: Session.Event
    ) async throws -> CryptoAccount {
        let accounts = try await coincore.cryptoAccounts(
            for: event.ref.context.decode(blockchain.ux.asset.id),
            supporting: action
        )
        if let id = try? event.ref.context.decode(blockchain.ux.asset.account.id, as: String.self) {
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
