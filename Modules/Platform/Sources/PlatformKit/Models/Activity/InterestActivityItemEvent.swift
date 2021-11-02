// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum InterestActivityItemEventState: String {
    case failed
    case rejected
    case processing
    case complete
    case pending
    case manualReview
    case cleared
    case refunded
    case unknown
}

public enum InterestTransactionType: String {
    case transfer
    case withdraw
    case interestEarned
    case unknown
}

public struct InterestAttributes: Decodable {
    let address: String
    let confirmations: Int
    let hash: String
    let identifier: String
    let transactionHash: String
    let beneficiary: InterestBeneficiary?
}

public struct InterestBeneficiary: Decodable {
    let user: String
    let accountRef: String
}

public struct InterestActivityItemEvent {
    public let value: CryptoValue
    public let cryptoCurrency: CryptoCurrency
    public let identifier: String
    public let insertedAt: Date
    public let state: InterestActivityItemEventState
    public let type: InterestTransactionType

    public init(
        value: CryptoValue,
        cryptoCurrency: CryptoCurrency,
        identifier: String,
        insertedAt: Date,
        state: InterestActivityItemEventState,
        type: InterestTransactionType
    ) {
        self.value = value
        self.cryptoCurrency = cryptoCurrency
        self.identifier = identifier
        self.insertedAt = insertedAt
        self.state = state
        self.type = type
    }
}
