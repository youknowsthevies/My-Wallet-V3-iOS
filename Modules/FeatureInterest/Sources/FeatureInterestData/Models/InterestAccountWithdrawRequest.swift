// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct InterestAccountWithdrawRequest: Encodable {
    let withdrawalAddress: String
    let amount: String
    let currency: String
}
