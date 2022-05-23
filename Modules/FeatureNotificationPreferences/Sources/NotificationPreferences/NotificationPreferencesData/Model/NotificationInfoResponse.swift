// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureNotificationPreferencesDomain
import Foundation

public struct NotificationInfoResponse: Decodable {
    let preferences: [NotificationPreferenceResponse]
    let notificationMethods: [NotificationMethodInfoResponse]
}

// MARK: - NotificationMethodInfoResponse

struct NotificationMethodInfoResponse: Decodable {
    let method: NotificationMethod
    let title: String
    let configured: Bool
    let verified: Bool
}

// MARK: - NotificationPreferenceResponse

struct NotificationPreferenceResponse: Decodable {
    let type: PreferenceType
    let title: String
    let subtitle: String
    let description: String
    let requiredMethods, optionalMethods, enabledMethods: [NotificationMethod]

    enum CodingKeys: String, CodingKey {
        case type
        case title
        case subtitle
        case description
        case requiredMethods, optionalMethods, enabledMethods
    }
}
