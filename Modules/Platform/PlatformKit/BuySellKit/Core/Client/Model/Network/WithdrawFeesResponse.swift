// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct CurrencyFeeResponse: Decodable {
    let symbol: String
    let value: String
}

struct WithdrawFeesResponse: Decodable {
    let fees: [CurrencyFeeResponse]
    let minAmounts: [CurrencyFeeResponse]
}
