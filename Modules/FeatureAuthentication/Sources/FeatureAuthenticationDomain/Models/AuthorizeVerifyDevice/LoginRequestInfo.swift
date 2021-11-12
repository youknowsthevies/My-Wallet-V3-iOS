// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct LoginRequestInfo: Equatable {
    public let sessionId: String
    public let base64Str: String
    public let details: DeviceVerificationDetails
    public let timestamp: Date

    public init(
        sessionId: String,
        base64Str: String,
        details: DeviceVerificationDetails,
        timestamp: Date
    ) {
        self.sessionId = sessionId
        self.base64Str = base64Str
        self.details = details
        self.timestamp = timestamp
    }
}
