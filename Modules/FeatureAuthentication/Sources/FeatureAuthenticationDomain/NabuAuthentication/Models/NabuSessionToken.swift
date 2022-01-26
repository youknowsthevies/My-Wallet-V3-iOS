// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct NabuSessionToken {

    public let identifier: String
    public let userId: String
    public let token: String
    public let isActive: Bool
    public let expiresAt: Date?

    public init(
        identifier: String,
        userId: String,
        token: String,
        isActive: Bool,
        expiresAt: Date?
    ) {
        self.identifier = identifier
        self.userId = userId
        self.token = token
        self.isActive = isActive
        self.expiresAt = expiresAt
    }
}
