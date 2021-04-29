// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct PortfolioBalanceChange: Codable {
    public let balance: Decimal
    public let changePercentage: Double
    public let change: Decimal
}

public extension PortfolioBalanceChange {
    static let zero: PortfolioBalanceChange = .init(
        balance: 0.0,
        changePercentage: 0.0,
        change: 0.0
    )
}
