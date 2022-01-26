//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

/// A data structure that represents the state of the user
struct UserState: Equatable {

    /// A data structure that represents the KYC status of the user
    enum KYCStatus: Equatable {
        case unverified
        case silver
        case silverPlus
        case gold

        var canPurchaseCrypto: Bool {
            switch self {
            case .unverified, .silver:
                return false
            case .silverPlus, .gold:
                return true
            }
        }
    }

    /// A data structure that represents a payment method the user has linked to their Blockchain.com account
    struct PaymentMethod: Identifiable, Equatable {
        let id: String
        let label: String
    }

    let kycStatus: KYCStatus
    let linkedPaymentMethods: [PaymentMethod]
    let hasEverPurchasedCrypto: Bool

    init(
        kycStatus: KYCStatus,
        linkedPaymentMethods: [PaymentMethod],
        hasEverPurchasedCrypto: Bool
    ) {
        self.kycStatus = kycStatus
        self.linkedPaymentMethods = linkedPaymentMethods
        self.hasEverPurchasedCrypto = hasEverPurchasedCrypto
    }
}
