// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import FeatureCoinDomain
import Foundation
import MoneyKit
import NetworkError
import SwiftUI

enum PreviewHelper {

    static func assetDetails(
        name: String = "Bitcoin",
        code: String = "BTC",
        brandColor: Color = .orange,
        // swiftlint:disable:next line_length
        about: String = "The world’s first cryptocurrency, Bitcoin is stored and exchanged securely on the internet through a digital ledger known as a blockchain. Bitcoins are divisible into smaller units known as satoshis — each satoshi is worth 0.00000001 bitcoin.",
        assetInfoUrl: URL = URL(string: "https://www.blockchain.com/")!,
        logoUrl: URL? = URL(string: "https://cryptologos.cc/logos/bitcoin-btc-logo.png"),
        logoImage: Image? = nil,
        tradeable: Bool = true,
        onWatchlist: Bool = true
    ) -> AssetDetails {
        AssetDetails(
            name: name,
            code: code,
            brandColor: brandColor,
            about: about,
            assetInfoUrl: assetInfoUrl,
            logoUrl: logoUrl,
            logoImage: logoImage,
            tradeable: tradeable
        )
    }

    static func account(
        id: AnyHashable = "id",
        name: String = "Private Key Wallet",
        accountType: Account.AccountType = .privateKey,
        cryptoCurrency: CryptoCurrency = .bitcoin,
        fiatCurrency: FiatCurrency = .USD,
        cryptoBalancePublisher: AnyPublisher<MoneyValue, Never> = .just(.init(amount: BigInt(123000000), currency: .crypto(.bitcoin))),
        fiatBalancePublisher: AnyPublisher<MoneyValue, Never> = .just(.init(amount: BigInt(4417223), currency: .fiat(.USD)))
    ) -> Account {
        Account(
            id: id,
            name: name,
            accountType: accountType,
            cryptoCurrency: cryptoCurrency,
            fiatCurrency: fiatCurrency,
            cryptoBalancePublisher: cryptoBalancePublisher,
            fiatBalancePublisher: fiatBalancePublisher
        )
    }

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
