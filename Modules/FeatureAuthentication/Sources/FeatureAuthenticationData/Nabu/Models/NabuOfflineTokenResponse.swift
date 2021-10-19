// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain

// TODO: make this internal by refactoring NabuAuthenticationExecutor (put that in FeatureAuthentication)
public struct NabuOfflineTokenResponse: Decodable, Equatable {

    enum CodingKeys: String, CodingKey {
        case userId
        case token
        case created
    }

    public let userId: String
    public let token: String
    public let created: Bool?

    public init(userId: String, token: String, created: Bool? = nil) {
        self.userId = userId
        self.token = token
        self.created = created
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        token = try container.decode(String.self, forKey: .token)
        created = try container.decodeIfPresent(Bool.self, forKey: .created)
    }

    public init(from token: NabuOfflineToken) {
        self.init(
            userId: token.userId,
            token: token.token,
            created: token.created
        )
    }
}

extension NabuOfflineToken {

    public init(from response: NabuOfflineTokenResponse) {
        self.init(
            userId: response.userId,
            token: response.token,
            created: response.created
        )
    }
}
