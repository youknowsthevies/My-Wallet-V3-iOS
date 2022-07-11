// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol CoinSortingStrategy {
    func sort(coins: [UnspentOutput]) -> [UnspentOutput]
}

/// Prioritizes smaller coins, better coin consolidation but a higher fee.
public struct AscentDrawSortingStrategy: CoinSortingStrategy {

    public init() {}

    public func sort(coins: [UnspentOutput]) -> [UnspentOutput] {
        coins.sorted(by: { lhs, rhs -> Bool in
            lhs.magnitude < rhs.magnitude
        })
    }
}

/// Prioritizes larger coins, worse coin consolidation but a lower fee.
public struct DescentDrawSortingStrategy: CoinSortingStrategy {

    public init() {}

    public func sort(coins: [UnspentOutput]) -> [UnspentOutput] {
        coins.sorted(by: { lhs, rhs -> Bool in
            lhs.magnitude > rhs.magnitude
        })
    }
}
