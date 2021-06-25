// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct BankTranferPaymentResponse: Decodable {
    let paymentId: String
    let bankAccountType: String?
}
