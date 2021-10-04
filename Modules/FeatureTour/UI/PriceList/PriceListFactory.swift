// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

enum PriceListFactory {

    private static var items: IdentifiedArrayOf<Price> {
        [
            Price(
                title: "0x",
                abbreviation: "ZRX",
                price: "$1.12",
                percentage: "↓ 6.90%",
                icon: Image("zrx", bundle: Bundle.featureTour),
                hasIncreased: false
            ),
            Price(
                title: "Aave",
                abbreviation: "AAVE",
                price: "$377.11",
                percentage: "↓ 5.07%",
                icon: Image("aave", bundle: Bundle.featureTour),
                hasIncreased: false
            ),
            Price(
                title: "Algorand",
                abbreviation: "ALGO",
                price: "$1.04",
                percentage: "↓ 7.04%",
                icon: Image("algo", bundle: Bundle.featureTour),
                hasIncreased: false
            ),
            Price(
                title: "Bitclout",
                abbreviation: "CLOUT",
                price: "$180.97",
                percentage: "↑ 2.45%",
                icon: Image("clout", bundle: Bundle.featureTour),
                hasIncreased: true
            ),
            Price(
                title: "Bitcoin",
                abbreviation: "BTC",
                price: "$38,152.31",
                percentage: "↓ 3.80%",
                icon: Image("btc", bundle: Bundle.featureTour),
                hasIncreased: false
            ),
            Price(
                title: "Bitcoin Cash",
                abbreviation: "BCH",
                price: "$1,113.99",
                percentage: "↑ 2.45%",
                icon: Image("bch", bundle: Bundle.featureTour),
                hasIncreased: true
            ),
            Price(
                title: "Bitcoin Satoshi Vission",
                abbreviation: "BSV",
                price: "$175.91",
                percentage: "↓ 6.76%",
                icon: Image("bsv", bundle: Bundle.featureTour),
                hasIncreased: false
            ),
            Price(
                title: "Dogecoin",
                abbreviation: "DOGE",
                price: "$0.38",
                percentage: "↓ 1.27%",
                icon: Image("doge", bundle: Bundle.featureTour),
                hasIncreased: false
            )
        ]
    }

    static func makePriceList() -> PriceListView {
        var doubleItems = items
        items.forEach { doubleItems.append($0) }
        return PriceListView(
            store: Store(
                initialState: PriceListState(items: doubleItems),
                reducer: priceListReducer,
                environment: PriceListEnvironment()
            )
        )
    }
}
