// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import TransactionKit

struct BankTranferPaymentResponse: Decodable {
    let paymentId: String
    let bankAccountType: String?
}

extension BankTranferPayment {

    init(response: BankTranferPaymentResponse) {
        self.init(
            paymentId: response.paymentId,
            bankAccountType: response.bankAccountType
        )
    }
}
