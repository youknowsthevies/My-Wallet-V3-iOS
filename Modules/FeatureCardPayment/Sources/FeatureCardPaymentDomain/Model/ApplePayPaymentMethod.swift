// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PassKit

public struct ApplePayPaymentMethod: Codable, Equatable {
    public let displayName: String
    public let network: String
    public let type: String
}

extension ApplePayPaymentMethod {
    public init?(paymentMethod: PKPaymentMethod) {
        guard let displayName = paymentMethod.displayName,
              let network = paymentMethod.network?.rawValue
        else {
            return nil
        }
        self.init(
            displayName: displayName,
            network: network,
            type: paymentMethod.type.typeString
        )
    }
}

extension PKPaymentMethodType {
    var typeString: String {
        switch self {
        case .credit:
            return "credit"
        case .unknown:
            return "unknown"
        case .debit:
            return "debit"
        case .eMoney:
            return "eMoney"
        case .prepaid:
            return "prepaid"
        case .store:
            return "store"
        @unknown default:
            return ""
        }
    }
}
