// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum ProductIdentifier: String, Hashable, Codable {
    case buy = "BUY"
    case swap = "SWAP"
    case custodialWallet = "CUSTODIAL_WALLET"
}

public struct ProductSuggestedUpgrade: Hashable, Codable {

    public let requiredTier: Int

    public init(requiredTier: Int) {
        self.requiredTier = requiredTier
    }
}

/// A type representing any kind of products
public protocol Product: Hashable, Identifiable {

    /// The product's identifier
    var id: ProductIdentifier { get }
    /// Whether or not the product/feature is enabled at all
    var enabled: Bool { get }
    /// If the product cannot be used or it's disabled, a suggeted upgrade may be available.
    var suggestedUpgrade: ProductSuggestedUpgrade? { get }
}

/// A wrapper to use any `Product` as ivars or return type. `Product` has constraints that don't make it compilable at this time.
/// The choice to make it an enum is to expose the underlying `Product` so the user can query data specific to the underlying type.
public enum ProductValue: Product {
    case trading(TradingProduct)
    case custodialWallet(CustodialWalletProduct)

    public var id: ProductIdentifier {
        let id: ProductIdentifier
        switch self {
        case .trading(let tradingProduct):
            id = tradingProduct.id
        case .custodialWallet(let custodialWalletProduct):
            id = custodialWalletProduct.id
        }
        return id
    }

    public var enabled: Bool {
        let enabled: Bool
        switch self {
        case .trading(let tradingProduct):
            enabled = tradingProduct.enabled
        case .custodialWallet(let custodialWalletProduct):
            enabled = custodialWalletProduct.enabled
        }
        return enabled
    }

    public var suggestedUpgrade: ProductSuggestedUpgrade? {
        let suggestedUpgrade: ProductSuggestedUpgrade?
        switch self {
        case .trading(let tradingProduct):
            suggestedUpgrade = tradingProduct.suggestedUpgrade
        case .custodialWallet(let custodialWalletProduct):
            suggestedUpgrade = custodialWalletProduct.suggestedUpgrade
        }
        return suggestedUpgrade
    }
}

public struct TradingProduct: Product, Codable {

    public let id: ProductIdentifier
    public let enabled: Bool
    public let maxOrdersCap: Int?
    public let maxOrdersLeft: Int?
    public let canPlaceOrder: Bool
    public let suggestedUpgrade: ProductSuggestedUpgrade?

    public init(
        id: ProductIdentifier,
        enabled: Bool,
        maxOrdersCap: Int?,
        maxOrdersLeft: Int?,
        canPlaceOrder: Bool,
        suggestedUpgrade: ProductSuggestedUpgrade?
    ) {
        self.id = id
        self.enabled = enabled
        self.maxOrdersCap = maxOrdersCap
        self.maxOrdersLeft = maxOrdersLeft
        self.canPlaceOrder = canPlaceOrder
        self.suggestedUpgrade = suggestedUpgrade
    }
}

public struct CustodialWalletProduct: Product, Codable {

    public let id: ProductIdentifier
    public let enabled: Bool
    public let canDepositFiat: Bool
    public let canDepositCrypto: Bool
    public let canWithdrawCrypto: Bool
    public let canWithdrawFiat: Bool
    public let suggestedUpgrade: ProductSuggestedUpgrade?

    public init(
        id: ProductIdentifier,
        enabled: Bool,
        canDepositFiat: Bool,
        canDepositCrypto: Bool,
        canWithdrawCrypto: Bool,
        canWithdrawFiat: Bool,
        suggestedUpgrade: ProductSuggestedUpgrade?
    ) {
        self.id = id
        self.enabled = enabled
        self.canDepositFiat = canDepositFiat
        self.canDepositCrypto = canDepositCrypto
        self.canWithdrawCrypto = canWithdrawCrypto
        self.canWithdrawFiat = canWithdrawFiat
        self.suggestedUpgrade = suggestedUpgrade
    }
}
