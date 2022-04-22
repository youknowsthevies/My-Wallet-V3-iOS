//
//  NotificationPreferences.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 11/04/2022.
//

import Foundation
import FeatureNotificationPreferencesDomain

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
