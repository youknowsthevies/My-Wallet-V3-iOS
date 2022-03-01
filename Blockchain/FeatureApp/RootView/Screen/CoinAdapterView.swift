//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
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

    var networkAdapter: NetworkAdapterAPI = resolve()
    var userAdapter: UserAdapterAPI = resolve()
    var coincore: CoincoreAPI = resolve()
    var fiatCurrencyService: FiatCurrencyServiceAPI = resolve()

    init(cryptoCurrency: CryptoCurrency) {
        store = Store<CoinViewState, CoinViewAction>(
            initialState: .init(
                assetDetails: AssetDetails(cryptoCurrency: cryptoCurrency)
            ),
            reducer: coinViewReducer,
            environment: CoinViewEnvironment(
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
                    HistoricalPriceClient(
                        .init(base: cryptoCurrency, quote: .USD),
                        request: RequestBuilder(
                            config: .init(scheme: "https", host: "api.blockchain.info")
                        ),
                        network: networkAdapter
                    )
                )
            )
        )
    }

    var body: some View {
        PrimaryNavigationView {
            CoinView(store: store)
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
            tradeable: true,
            onWatchlist: false
        )
    }
}
