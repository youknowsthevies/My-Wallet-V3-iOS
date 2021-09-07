// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms
import BigInt
import PlatformKit
import ToolKit

final class PricesInterpolator {

    private let prices: [OrderPriceTier]

    init(prices: [OrderPriceTier]) {
        self.prices = [.zero] + prices
    }

    func rate(amount: BigInt) -> BigInt {
        let tier = prices
            .lazy
            .adjacentPairs()
            .compactMap { tier, next -> BigInt? in
                let current = (
                    volume: BigInt(tier.volume)!,
                    price: BigInt(tier.price)!
                )
                let next = (
                    volume: BigInt(next.volume)!,
                    price: BigInt(next.price)!
                )
                guard current.volume < amount, amount <= next.volume else {
                    return nil
                }
                guard current.price != .zero else {
                    return next.price
                }
                return LinearInterpolator
                    .interpolate(
                        x: [current.volume, next.volume],
                        y: [current.price, next.price],
                        xi: amount
                    )
            }.first
        return tier
            ?? prices.last.flatMap { BigInt($0.price) }
            ?? .zero
    }
}
