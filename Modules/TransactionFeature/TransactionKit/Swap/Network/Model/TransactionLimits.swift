// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct TransactionLimits: Decodable {
    public let currency: FiatCurrency
    public let minOrder: FiatValue
    public let maxOrder: FiatValue
    public let maxPossibleOrder: FiatValue
    public let daily: TransactionLimit?
    public let weekly: TransactionLimit?
    public let annual: TransactionLimit?

    public var maxTradableToday: FiatValue {
        daily?.available ?? maxPossibleOrder
    }

    enum CodingKeys: String, CodingKey {
        case currency
        case minOrder
        case maxOrder
        case maxPossibleOrder
        case daily
        case weekly
        case annual
    }

    struct Limit: Decodable {
        let limit: String
        let available: String
        let used: String
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currency = try values.decode(FiatCurrency.self, forKey: .currency)
        let zero = FiatValue.zero(currency: currency)

        minOrder = FiatValue.create(
            minor: try values.decode(String.self, forKey: .minOrder),
            currency: currency
        ) ?? zero
        maxPossibleOrder = FiatValue.create(
            minor: try values.decode(String.self, forKey: .maxPossibleOrder),
            currency: currency
        ) ?? zero
        maxOrder = FiatValue.create(
            minor: try values.decode(String.self, forKey: .maxOrder),
            currency: currency
        ) ?? zero

        if let daily = try values.decodeIfPresent(Limit.self, forKey: .daily) {
            self.daily = .init(fiatCurrency: currency, limit: daily)
        } else {
            self.daily = nil
        }
        if let weekly = try values.decodeIfPresent(Limit.self, forKey: .weekly) {
            self.weekly = .init(fiatCurrency: currency, limit: weekly)
        } else {
            self.weekly = nil
        }
        if let annual = try values.decodeIfPresent(Limit.self, forKey: .annual) {
            self.annual = .init(fiatCurrency: currency, limit: annual)
        } else {
            self.annual = nil
        }
    }
}
