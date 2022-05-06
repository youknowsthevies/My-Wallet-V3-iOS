// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AccountCredentialsEntryPayload: MetadataNodeEntry, Hashable {

    public enum CodingKeys: String, CodingKey {
        case nabuUserId = "nabu_user_id"
        case nabuLifetimeToken = "nabu_lifetime_token"
        case exchangeUserId = "exchange_user_id"
        case exchangeLifetimeToken = "exchange_lifetime_token"
    }

    public static let type: EntryType = .accountCredentials

    public let nabuUserId: String
    public let nabuLifetimeToken: String
    public let exchangeUserId: String?
    public let exchangeLifetimeToken: String?

    public init(
        nabuUserId: String,
        nabuLifetimeToken: String,
        exchangeUserId: String?,
        exchangeLifetimeToken: String?
    ) {
        self.nabuUserId = nabuUserId
        self.nabuLifetimeToken = nabuLifetimeToken
        self.exchangeUserId = exchangeUserId
        self.exchangeLifetimeToken = exchangeLifetimeToken
    }
}
