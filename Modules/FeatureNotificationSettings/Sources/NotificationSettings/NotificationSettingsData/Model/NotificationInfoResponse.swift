//
//  NotificationPreferences.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 11/04/2022.
//

import Foundation
import FeatureNotificationSettingsDomain

public struct NotificationInfoResponse: Decodable {
    let preferences: [NotificationPreferenceResponse]
    let notificationMethods: [NotificationMethodInfoResponse]
    let language: String
}

// MARK: - NotificationMethodInfoResponse
struct NotificationMethodInfoResponse: Decodable {
    let method: NotificationMethod
    let title: String
    let configured, verified: Bool
}

// MARK: - NotificationPreferenceResponse
struct NotificationPreferenceResponse: Decodable {
    let type: PreferenceType
    let title, preferenceDescription: String
    let requiredMethods, optionalMethods, enabledMethods: [NotificationMethod]

    enum CodingKeys: String, CodingKey {
        case type, title
        case preferenceDescription = "description"
        case requiredMethods, optionalMethods, enabledMethods
    }
}
