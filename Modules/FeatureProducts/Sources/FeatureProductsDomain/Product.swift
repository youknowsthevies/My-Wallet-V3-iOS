// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct Product: Hashable, Identifiable {

    public enum Identifier: String, Hashable {
        case buy = "BUY"
        case swap = "SWAP"
    }

    public struct SuggestedUpgrade: Hashable {

        public let requiredTier: Int

        public init(requiredTier: Int) {
            self.requiredTier = requiredTier
        }
    }

    public let id: Identifier
    public let maxOrdersCap: Int
    public let canPlaceOrder: Bool
    public let suggestedUpgrade: SuggestedUpgrade?

    public init(
        id: Identifier,
        maxOrdersCap: Int,
        canPlaceOrder: Bool,
        suggestedUpgrade: SuggestedUpgrade?
    ) {
        self.id = id
        self.maxOrdersCap = maxOrdersCap
        self.canPlaceOrder = canPlaceOrder
        self.suggestedUpgrade = suggestedUpgrade
    }
}

// Temporary helpers while discussing API design changes
extension Product {

    public var enabled: Bool {
        canPlaceOrder
    }

    /// use this API as a proxy for `enabled` + any other metadata related to the specific product?
    public var canBeUsed: Bool {
        canPlaceOrder
    }
}
