// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct InterestAccountTransferRequest: Encodable {
    let amount: String
    let currency: String
    let origin: String
    let destination: String
}

extension InterestAccountTransferRequest {

    static func createTransferRequestWithAmount(
        _ amount: String,
        currencyCode: String
    ) -> InterestAccountTransferRequest {
        .init(
            amount: amount,
            currency: currencyCode,
            origin: "SIMPLEBUY",
            destination: "SAVINGS"
        )
    }

    static func createWithdrawRequestWithAmount(
        _ amount: String,
        currencyCode: String
    ) -> InterestAccountTransferRequest {
        .init(
            amount: amount,
            currency: currencyCode,
            origin: "SAVINGS",
            destination: "SIMPLEBUY"
        )
    }
}
