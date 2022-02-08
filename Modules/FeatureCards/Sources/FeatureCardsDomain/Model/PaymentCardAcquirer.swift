// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct PaymentCardAcquirer: Decodable, Equatable {
    public let cardAcquirerName: CardPayload.Acquirer
    /// List of the accounts (stripe_uk, stripe_us)
    public let cardAcquirerAccountCodes: [String]
    public let apiKey: String

    public init(
        cardAcquirerName: CardPayload.Acquirer,
        cardAcquirerAccountCodes: [String],
        apiKey: String
    ) {
        self.cardAcquirerName = cardAcquirerName
        self.cardAcquirerAccountCodes = cardAcquirerAccountCodes
        self.apiKey = apiKey
    }
}
