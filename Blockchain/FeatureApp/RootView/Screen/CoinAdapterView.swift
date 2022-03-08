//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureCoinData
import FeatureCoinDomain
import FeatureCoinUI
import FeatureInterestUI
import FeatureTransactionUI
import MoneyKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

struct CoinAdapterView: View {

    let store: Store<CoinViewState, CoinViewAction>
    let currency: CryptoCurrency

    init(
        cryptoCurrency: CryptoCurrency,
        app: AppProtocol = resolve(),
        userAdapter: UserAdapterAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        historicalPriceRepository: HistoricalPriceRepositoryAPI = resolve(),
        ratesRepository: RatesRepositoryAPI = resolve()
    ) {
        currency = cryptoCurrency
        store = Store<CoinViewState, CoinViewAction>(
            initialState: .init(
                assetDetails: AssetDetails(cryptoCurrency: cryptoCurrency)
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
                        .flatMap { [coincore] fiatCurrency in
                            coincore.cryptoAccounts(for: cryptoCurrency)
                                .map { accounts in
                                    accounts
                                        .filter { !($0 is ExchangeAccount) }
                                        .map { Account($0, fiatCurrency) }
                                }
                                .replaceError(with: [])
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                },
                historicalPriceService: HistoricalPriceService(
                    base: cryptoCurrency,
                    displayFiatCurrency: fiatCurrencyService.displayCurrencyPublisher,
                    historicalPriceRepository: historicalPriceRepository
                ),
                interestRatesRepository: ratesRepository
            )
        )
    }

    var body: some View {
        CoinView(store: store)
            .context([blockchain.ux.asset.id: currency.code])
    }
}

struct CoinViewObserver: AppSessionObserver {

    var transactionsRouter: TransactionsRouterAPI = resolve()
    var coincore: CoincoreAPI = resolve()

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
                switch try await cryptoAccount(for: .interestWithdraw, from: event) {
                case let account as CryptoInterestAccount:
                    await transactionsRouter.presentTransactionFlow(to: .interestWithdraw(account))
                default:
                    throw event.tag.error("Withdrawing from rewards requires CryptoInterestAccount")
                }
            }
            .on(blockchain.ux.asset.account.rewards.deposit) { event in
                switch try await cryptoAccount(for: .interestTransfer, from: event) {
                case let account as CryptoInterestAccount:
                    await transactionsRouter.presentTransactionFlow(to: .interestTransfer(account))
                default:
                    throw event.tag.error("Transferring to rewards requires CryptoInterestAccount")
                }
            }
            .on(blockchain.ux.asset.account.rewards.summary) { event in
                let account = try await cryptoAccount(for: .interestTransfer, from: event)
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
            .on(blockchain.ux.asset.account.require.KYC) { event in
                fatalError("\(event.ref) KYC")
            }
            .on(blockchain.ux.asset.account.activity) { event in
                fatalError("\(event.ref) activity")
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
        .or(throw: event.tag.error(message: "No trading account found for \(event.ref)"))
    }

    func cryptoAccount(
        for action: AssetAction? = nil,
        from event: Session.Event
    ) async throws -> CryptoAccount {
        let accounts = try await coincore.cryptoAccounts(
            for: event.context.decode(blockchain.ux.asset.id),
            supporting: action
        )
        if let id = try? event.context.decode(blockchain.ux.asset.account.id, as: String.self) {
            return try accounts.first(where: { account in account.identifier == id as AnyHashable })
                .or(throw: event.tag.error(message: "No account found with id \(id)"))
        } else {
            return try (accounts.first(where: { account in account is TradingAccount }) ?? accounts.first)
                .or(throw: event.tag.error(message: "\(event) has no valid accounts for \(String(describing: action))"))
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
            cryptoBalancePublisher: account.balancePublisher.ignoreFailure(),
            fiatBalancePublisher: account.fiatBalance(fiatCurrency: fiatCurrency).ignoreFailure()
        )
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
            about: "About Test",
            assetInfoUrl: URL(string: "https://blockchain.com")!,
            logoUrl: cryptoCurrency.assetModel.logoPngUrl.flatMap(URL.init(string:)),
            logoImage: cryptoCurrency.assetModel.logoResource.image,
            tradeable: cryptoCurrency.supports(product: .custodialWalletBalance)
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
