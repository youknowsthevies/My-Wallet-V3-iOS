//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureCoinData
import FeatureCoinDomain
import FeatureCoinUI
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
    var app: AppProtocol = resolve()
    var networkAdapter: NetworkAdapterAPI = resolve()
    var userAdapter: UserAdapterAPI = resolve()
    var coincore: CoincoreAPI = resolve()
    var fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    var transactionsRouter: TransactionsRouterAPI = resolve()

    var historicalPriceRepository: HistoricalPriceRepositoryAPI = resolve()
    var ratesRepository: RatesRepositoryAPI = resolve()

    init(cryptoCurrency: CryptoCurrency) {
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
        PrimaryNavigationView {
            CoinView(store: store)
                .on(blockchain.ux.asset.buy, blockchain.ux.asset.account.buy) { event in
                    try await transactionsRouter
                        .presentTransactionFlow(to: .buy(crypto(action: .buy, in: event)))
                }
                .on(blockchain.ux.asset.sell, blockchain.ux.asset.account.sell) { event in
                    try await transactionsRouter
                        .presentTransactionFlow(to: .sell(crypto(action: .sell, in: event)))
                }
                .on(blockchain.ux.asset.receive, blockchain.ux.asset.account.receive) { event in
                    try await transactionsRouter
                        .presentTransactionFlow(to: .receive(crypto(action: .receive, in: event)))
                }
                .on(blockchain.ux.asset.send, blockchain.ux.asset.account.send) { event in
                    try await transactionsRouter
                        .presentTransactionFlow(to: .send(crypto(action: .send, in: event), nil))
                }
                .on(blockchain.ux.asset.account.swap) { event in
                    try await transactionsRouter
                        .presentTransactionFlow(to: .swap(crypto(action: .swap, in: event)))
                }
                .on(blockchain.ux.asset.account.withdraw) { event in
                    fatalError("\(event.ref) withdraw")
                }
                .on(blockchain.ux.asset.account.deposit) { event in
                    fatalError("\(event.ref) deposit")
                }
                .on(blockchain.ux.asset.account.require.KYC) { event in
                    fatalError("\(event.ref) KYC")
                }
                .on(blockchain.ux.asset.account.activity) { event in
                    fatalError("\(event.ref) activity")
                }
                .app(app)
                .context([blockchain.ux.asset.id: currency.code])
        }
    }

    func crypto(
        action: AssetAction,
        in event: Session.Event
    ) async throws -> CryptoAccount {
        let accounts = try await coincore.cryptoAccounts(
            for: event.ref.context.decode(blockchain.ux.asset.id),
            supporting: action
        )
        if let id = try? event.ref.context.decode(blockchain.ux.asset.account.id, as: String.self) {
            return try accounts.first(where: { account in account.identifier == id as AnyHashable })
                .or(throw: event.tag.error(message: "No account found with id \(id)"))
        } else {
            return try (accounts.first(where: { account in account is TradingAccount }) ?? accounts.first)
                .or(throw: event.tag.error(message: "\(event) has no valid accounts for \(action)"))
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
