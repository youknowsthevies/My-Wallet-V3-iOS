// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Collections
import Combine
import FeatureCoinDomain
import Foundation
import MoneyKit
import NetworkError
import SwiftUI
import ToolKit

extension CryptoCurrency {

    public static let notTradable = CryptoCurrency(
        assetModel: AssetModel(
            code: "BTC",
            displayCode: "BTC",
            kind: .coin(minimumOnChainConfirmations: 2),
            name: "Bitcoin",
            precision: 8,
            products: [],
            logoPngUrl: nil,
            spotColor: "FF9B22",
            sortIndex: 1
        )
    )!
}

extension Account.Snapshot {

    static var preview = (
        privateKey: Account.Snapshot.new(
            id: "PrivateKey",
            name: "Private Key Wallet",
            accountType: .privateKey,
            actions: [.send, .receive, .activity]
        ),
        trading: Account.Snapshot.new(
            id: "Trading",
            name: "Trading Account",
            accountType: .trading,
            actions: [.buy, .sell, .send, .receive, .swap, .activity]
        ),
        rewards: Account.Snapshot.new(
            id: "Rewards",
            name: "Rewards Account",
            accountType: .interest,
            actions: [.rewards.withdraw, .rewards.deposit]
        ),
        exchange: Account.Snapshot.new(
            id: "Exchange",
            name: "Exchange Account",
            accountType: .exchange,
            actions: [.exchange.withdraw, .exchange.deposit]
        )
    )

    static func new(
        id: AnyHashable = "PrivateKey",
        name: String = "Private Key Wallet",
        accountType: Account.AccountType = .privateKey,
        cryptoCurrency: CryptoCurrency = .bitcoin,
        fiatCurrency: FiatCurrency = .USD,
        actions: OrderedSet<Account.Action> = [.send, .receive],
        crypto: MoneyValue = .init(amount: BigInt(123000000), currency: .crypto(.bitcoin)),
        fiat: MoneyValue = .init(amount: BigInt(4417223), currency: .fiat(.USD))
    ) -> Account.Snapshot {
        Account.Snapshot(
            id: id,
            name: name,
            accountType: accountType,
            cryptoCurrency: cryptoCurrency,
            fiatCurrency: fiatCurrency,
            actions: actions,
            crypto: crypto,
            fiat: fiat
        )
    )!
}

enum PreviewHelper {

    class HistoricalPriceService: HistoricalPriceServiceAPI {
        func fetch(
            series: Series,
            relativeTo: Date
        ) -> AnyPublisher<GraphData, NetworkError> {
            .just(
                GraphData(
                    series: stride(
                        from: Double.pi,
                        to: series.cycles * Double.pi,
                        by: Double.pi / Double(180)
                    )
                    .map { sin($0) + 1 }
                    .enumerated()
                    .map {
                        .init(
                            price: $1 * 10,
                            timestamp: Date(timeIntervalSinceNow: Double($0) * 60 * series.cycles)
                        )
                    },
                    base: .bitcoin,
                    quote: .USD
                )
            )
        }
    }

    class InterestRatesRepository: RatesRepositoryAPI {
        func fetchRate(
            code: String
        ) -> AnyPublisher<Double, NetworkError> {
            .just(5 / 3)
        }
    }

    class WatchlistRepository: WatchlistRepositoryAPI {
        func addToWatchlist(
            _ assetCode: String
        ) -> AnyPublisher<Void, NetworkError> {
            .just(())
        }

        func removeFromWatchlist(
            _ assetCode: String
        ) -> AnyPublisher<Void, NetworkError> {
            .just(())
        }

        func getWatchlist() -> AnyPublisher<Set<String>, NetworkError> {
            .just(Set())
        }
    }
}

extension Series {

    fileprivate var cycles: Double {
        switch self {
        case .day:
            return 2
        case .week:
            return 3
        case .month:
            return 4
        case .year:
            return 5
        case .all:
            return 6
        default:
            return 1
        }
    }
}
