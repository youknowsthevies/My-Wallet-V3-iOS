// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct NabuOfflineToken: Equatable {

    // Nabu credentials - normal & unified accounts
    public let userId: String
    public let token: String

    // Exchange credentials - unified accounts
    public let exchangeUserId: String?
    public let exchangeOfflineToken: String?

    public let created: Bool?

    public init(
        userId: String,
        token: String,
        exchangeUserId: String? = nil,
        exchangeOfflineToken: String? = nil,
        created: Bool? = nil
    ) {
        self.userId = userId
        self.token = token
        self.exchangeUserId = exchangeUserId
        self.exchangeOfflineToken = exchangeOfflineToken
        self.created = created
    }
}
