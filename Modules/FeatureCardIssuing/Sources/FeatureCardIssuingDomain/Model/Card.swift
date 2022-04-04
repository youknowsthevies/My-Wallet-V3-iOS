// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Card: Codable, Equatable {

    public let cardId: String

    public let type: CardType

    public let last4: String

    /// Expiry date of the card in mm/yy format
    public let expiry: String

    public let brand: Brand

    public let cardStatus: Status

    public let orderStatus: [OrderStatus]?

    public let createdAt: String
}

extension Card {

    public enum CardType: String, Codable {
        case virtual = "VIRTUAL"
        case physical = "PHYSICAL"
    }

    public enum Brand: String, Codable {
        case visa = "VISA"
        case mastercard = "MASTERCARD"
    }

    public enum Status: String, Codable {
        case created = "CREATED"
        case active = "ACTIVE"
        case terminated = "TERMINATED"
    }

    public struct OrderStatus: Codable, Equatable {
        let status: Status
        let date: Date
    }

    public struct Address: Codable, Equatable {

        public init(
            line1: String?,
            line2: String?,
            city: String?,
            postcode: String?,
            state: String?,
            country: String
        ) {
            self.line1 = line1
            self.line2 = line2
            self.city = city
            self.postcode = postcode
            self.state = state
            self.country = country
        }

        public let line1: String?

        public let line2: String?

        public let city: String?

        public let postcode: String?

        public let state: String?

        /// Country code in ISO-2
        public let country: String
    }
}

extension Card.OrderStatus {

    public enum Status: String, Codable {
        case ordered = "ORDERED"
        case shipped = "SHIPPED"
        case delivered = "DELIVERED"
    }
}

extension Card {

    var creationDate: Date? {
        DateFormatter.iso8601Format.date(from: createdAt)
    }
}
