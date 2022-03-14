// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PassKit

public struct ApplePayToken: Codable, Equatable {
    public let paymentData: ApplePayTokenData
    public let paymentMethod: ApplePayPaymentMethod
    public let transactionIdentifier: String
}

extension ApplePayToken {
    init?(token: PKPaymentToken) {
        guard let paymentData = try? JSONDecoder().decode(ApplePayTokenData.self, from: token.paymentData),
              let paymentMethod = ApplePayPaymentMethod(paymentMethod: token.paymentMethod)
        else {
            return nil
        }

        self.init(
            paymentData: paymentData,
            paymentMethod: paymentMethod,
            transactionIdentifier: token.transactionIdentifier
        )
    }
}
