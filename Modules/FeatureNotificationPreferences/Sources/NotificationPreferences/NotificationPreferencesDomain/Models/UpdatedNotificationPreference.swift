// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct UpdatedPreferences: Encodable, Equatable {
    let preferences: [UpdatedNotificationPreference]

    public init(preferences: [UpdatedNotificationPreference]) {
        self.preferences = preferences
    }
}

public struct UpdatedNotificationPreference: Encodable, Equatable {
    let contactMethod: String
    let channel: String
    let action: String

    public init(contactMethod: String, channel: String, action: String) {
        self.contactMethod = contactMethod
        self.channel = channel
        self.action = action
    }
}
