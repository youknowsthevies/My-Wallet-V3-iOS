// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct CurrencyFeeResponse: Decodable {
    public let symbol: String
    public let minorValue: String
}

public struct WithdrawFeesResponse: Decodable {
    public let fees: [CurrencyFeeResponse]
    public let minAmounts: [CurrencyFeeResponse]
}
