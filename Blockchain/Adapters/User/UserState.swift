//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import FeatureProductsDomain

enum UserStateError: Error {
    case missingBalance(Error)
    case missingKYCInfo(Error)
    case missingPaymentInfo(Error)
    case missingProductsInfo(Error)
    case missingPurchaseHistory(Error)
}

extension UserStateError: Equatable {

    static func == (lhs: UserStateError, rhs: UserStateError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}

/// A data structure that represents the state of the user
struct UserState: Equatable {

    /// A data structure wrapping key information about the user's holdings
    struct BalanceData: Equatable {
        let hasAnyBalance: Bool
        let hasAnyFiatBalance: Bool
        let hasAnyCryptoBalance: Bool
    }

    /// A data structure that represents the KYC status of the user
    enum KYCStatus: Equatable {
        case unverified
        case inReview
        case silver
        case silverPlus
        case gold

        var canPurchaseCrypto: Bool {
            switch self {
            case .unverified, .silver:
                return false
            case .silverPlus, .gold, .inReview:
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
    let balanceData: BalanceData
    let linkedPaymentMethods: [PaymentMethod]
    let hasEverPurchasedCrypto: Bool
    let products: [Product]
}

extension UserState {

    func canUse(_ productId: Product.Identifier?) -> Bool {
        guard let product = product(id: productId) else {
            // Let users use products we don't have information for
            return true
        }
        return product.canBeUsed
    }

    func requiredTierToUse(_ productId: Product.Identifier?) -> Int? {
        guard let product = product(id: productId) else {
            return nil
        }
        return product.suggestedUpgrade?.requiredTier
    }

    private func product(id: Product.Identifier?) -> Product? {
        guard let id = id, let product = products.first(where: { $0.id == id }) else {
            return nil
        }
        return product
    }
}
