// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct WithdrawalAmountResponse: Decodable {

    public let symbol: String
    public let value: String
}

public struct WithdrawalCheckoutResponse: Decodable {

    public let id: String
    public let user: String
    public let product: String
    public let state: String
    public let amount: WithdrawalAmountResponse
}
