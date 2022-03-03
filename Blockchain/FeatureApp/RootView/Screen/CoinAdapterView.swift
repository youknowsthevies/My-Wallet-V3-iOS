//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import FeatureCoinData
import FeatureCoinDomain
import FeatureCoinUI
import MoneyKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import SwiftUI

struct CoinAdapterView: View {
    let store: Store<CoinViewState, CoinViewAction>

    let currency: CryptoCurrency
    var app: AppProtocol = resolve()
    var networkAdapter: NetworkAdapterAPI = resolve()
    var userAdapter: UserAdapterAPI = resolve()
    var coincore: CoincoreAPI = resolve()
    var fiatCurrencyService: FiatCurrencyServiceAPI = resolve()

    var historicalPriceRepository: HistoricalPriceRepositoryAPI = resolve()

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
                )
            )
        )
    }

    var body: some View {
        PrimaryNavigationView {
            CoinView(store: store)
                .on(blockchain.ux.asset.buy) { event in
                    print("🐢 BUY", event.ref)
                }
                .on(blockchain.ux.asset.sell) { event in
                    print("🐢 SELL", event.ref)
                }
                .on(blockchain.ux.asset.receive) { event in
                    print("🐢 RECEIVE", event.ref)
                }
                .on(blockchain.ux.asset.send) { event in
                    print("🐢 SEND", event.ref)
                }
                .on(blockchain.ux.asset.account.receive) { event in
                    print("🐢 ALL", event.ref)
                }
                .on(blockchain.ux.asset.account.receive[].ref(to: [blockchain.ux.asset.account.id: "CryptoInterestAccount.ETH"])) { event in
                    print("🐢 INTEREST ONLY", event.ref)
                }
                .app(app)
                .context([blockchain.ux.asset.id: currency.code])
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
