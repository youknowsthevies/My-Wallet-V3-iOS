// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A product's DTO as returned by the BE API.
/// - Note: Needs to be public to be able to make the APIClient interface public.
public struct ProductAPIResponse: Hashable, Identifiable, Codable {

    public struct SuggestedUpgrade: Codable, Hashable {

        let requiredTier: Int
    }

    public let id: String
    public let maxOrdersCap: Int
    public let canPlaceOrder: Bool
    public let suggestedUpgrade: SuggestedUpgrade?
}

/// A DTO representing multiple products as returned by the BE API.
/// - Note: Needs to be public to be able to make the APIClient interface public.
public struct ProductsAPIResponse: Codable, Hashable {

    public let products: [ProductAPIResponse]
}
