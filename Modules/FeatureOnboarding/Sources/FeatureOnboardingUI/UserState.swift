// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A data type representing the user state for Onboarding
public struct UserState: Equatable {

    public enum KYCStatus: Equatable {
        case incomplete
        case pending
        case complete
    }

    public let kycStatus: KYCStatus
    public let hasLinkedPaymentMethods: Bool
    public let hasEverPurchasedCrypto: Bool

    public init(
        kycStatus: KYCStatus,
        hasLinkedPaymentMethods: Bool,
        hasEverPurchasedCrypto: Bool
    ) {
        self.kycStatus = kycStatus
        self.hasLinkedPaymentMethods = hasLinkedPaymentMethods
        self.hasEverPurchasedCrypto = hasEverPurchasedCrypto
    }
}
