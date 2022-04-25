// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureNotificationPreferencesDomain
import Foundation

public struct NotificationInfoResponse: Decodable {
    let preferences: [NotificationPreferenceResponse]
    let notificationMethods: [NotificationMethodInfoResponse]
//    let language: String
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
    let description: String
    let requiredMethods, optionalMethods, enabledMethods: [NotificationMethod]

    enum CodingKeys: String, CodingKey {
        case type, title
        case description
        case requiredMethods, optionalMethods, enabledMethods
    }
}
