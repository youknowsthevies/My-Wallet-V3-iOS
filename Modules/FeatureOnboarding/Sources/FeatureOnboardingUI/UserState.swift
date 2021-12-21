// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A data type representing the user state for Onboarding
public struct UserState: Equatable {

    public let hasCompletedKYC: Bool
    public let hasLinkedPaymentMethods: Bool
    public let hasEverPurchasedCrypto: Bool

    public init(
        hasCompletedKYC: Bool,
        hasLinkedPaymentMethods: Bool,
        hasEverPurchasedCrypto: Bool
    ) {
        self.hasCompletedKYC = hasCompletedKYC
        self.hasLinkedPaymentMethods = hasLinkedPaymentMethods
        self.hasEverPurchasedCrypto = hasEverPurchasedCrypto
    }
}
