// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct BitpayPaymentRequest: Decodable {

    var outputs: [Output] {
        instructions
            .map { $0.outputs }
            .flatMap { $0 }
    }

    let memo: String
    let expires: String
    let paymentUrl: String
    let paymentId: String

    private let instructions: [BitpayInstructions]
}

struct BitpayInstructions: Decodable {
    let outputs: [Output]
}

struct Output: Decodable {
    let amount: Int
    let address: String
}
