// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct NabuOfflineToken: Equatable {

    public let userId: String
    public let token: String
    public let created: Bool?

    public init(userId: String, token: String, created: Bool? = nil) {
        self.userId = userId
        self.token = token
        self.created = created
    }
}
