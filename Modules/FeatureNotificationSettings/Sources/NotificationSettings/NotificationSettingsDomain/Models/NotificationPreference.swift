//
//  NotificationPreference.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 11/04/2022.
//

import Foundation

struct NotificationInfo {
    public init(preferences: [NotificationPreference], notificationMethods: [NotificationMethodInfo], language: String) {
        self.preferences = preferences
        self.notificationMethods = notificationMethods
        self.language = language
    }
    
    let preferences: [NotificationPreference]
    let notificationMethods: [NotificationMethodInfo]
    let language: String
}

public struct NotificationMethodInfo: Hashable, Identifiable {
    public init(id: UUID = UUID(), method: NotificationMethod, title: String, configured: Bool, verified: Bool) {
        self.id = id
        self.method = method
        self.title = title
        self.configured = configured
        self.verified = verified
    }
        
    public var id = UUID()
    public let method: NotificationMethod
    public let title: String
    public let configured, verified: Bool
}

public struct NotificationPreference: Hashable, Identifiable {
    public init(id: UUID = UUID(), type: PreferenceType, title: String, preferenceDescription: String, requiredMethods: [NotificationMethodInfo], optionalMethods: [NotificationMethodInfo], enabledMethods: [NotificationMethodInfo]) {
        self.id = id
        self.type = type
        self.title = title
        self.preferenceDescription = preferenceDescription
        self.requiredMethods = requiredMethods
        self.optionalMethods = optionalMethods
        self.enabledMethods = enabledMethods
    }
    
    public var id = UUID()
    public let type: PreferenceType
    public let title, preferenceDescription: String
    public let requiredMethods, optionalMethods, enabledMethods: [NotificationMethodInfo]
}


public enum PreferenceType: String, Decodable {
    case transactional = "TRANSACTIONAL"
    case security = "SECURITY"
    case marketing = "MARKETING"
    case priceAlert = "PRICE_ALERT"
}

public enum NotificationMethod: String, Decodable,Identifiable {
    public var id: String { rawValue }
    
    case sms = "SMS"
    case email = "EMAIL"
    case push = "PUSH"
    case inApp = "IN_APP"
}
