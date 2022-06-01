// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureNotificationPreferencesDomain
import Foundation

public enum MockGenerator {
    static let emailMethod = NotificationMethodInfo(
        id: UUID(),
        method: .email,
        title: "E-Mail",
        configured: true,
        verified: true
    )

    static let inAppMethod = NotificationMethodInfo(
        id: UUID(),
        method: .inApp,
        title: "In-App",
        configured: true,
        verified: true
    )

    static let smsMethod = NotificationMethodInfo(
        id: UUID(),
        method: .sms,
        title: "SMS",
        configured: true,
        verified: true
    )

    static let pushMethod = NotificationMethodInfo(
        id: UUID(),
        method: .push,
        title: "Push",
        configured: true,
        verified: true
    )

    static let requiredMethods = [
        emailMethod
    ]

    static let optionalMethods = [
        emailMethod,
        inAppMethod,
        smsMethod
    ]

    static let enabledMethods = [
        inAppMethod,
        emailMethod
    ]

    public static let priceAlertNotificationPreference = NotificationPreference(
        id: UUID(),
        type: .priceAlert,
        title: "Price alerts",
        subtitle: "Push & Email",
        preferenceDescription: "Sent when a particular asset increases or decreases in price",
        requiredMethods: requiredMethods,
        optionalMethods: optionalMethods,
        enabledMethods: enabledMethods
    )

    public static let transactionalNotificationPreference = NotificationPreference(
        id: UUID(),
        type: .transactional,
        title: "Transactional notifications",
        subtitle: "Push & Email",
        preferenceDescription: "Sent when a particular asset increases or decreases in price",
        requiredMethods: requiredMethods,
        optionalMethods: optionalMethods,
        enabledMethods: enabledMethods
    )

    public static let securityNotificationPreference = NotificationPreference(
        id: UUID(),
        type: .security,
        title: "Security notifications",
        subtitle: "Push & Email",
        preferenceDescription: "Sent when a particular asset increases or decreases in price",
        requiredMethods: requiredMethods,
        optionalMethods: optionalMethods,
        enabledMethods: enabledMethods
    )

    public static let marketingNotificationPreference = NotificationPreference(
        id: UUID(),
        type: .marketing,
        title: "Marketing notifications",
        subtitle: "Push & Email",
        preferenceDescription: "Sent when a particular asset increases or decreases in price",
        requiredMethods: requiredMethods,
        optionalMethods: optionalMethods,
        enabledMethods: enabledMethods
    )

    public static let updatedNotificationPreference = UpdatedNotificationPreference(
        contactMethod: NotificationMethod.inApp.rawValue,
        channel: PreferenceType.marketing.rawValue,
        action: "ENABLE"
    )
    static let updatedPreferencesBundle = [
        UpdatedNotificationPreference(
            contactMethod: NotificationMethod.inApp.rawValue,
            channel: PreferenceType.marketing.rawValue,
            action: "ENABLE"
        ),
        UpdatedNotificationPreference(
            contactMethod: NotificationMethod.sms.rawValue,
            channel: PreferenceType.marketing.rawValue,
            action: "ENABLE"
        ),
        UpdatedNotificationPreference(
            contactMethod: NotificationMethod.push.rawValue,
            channel: PreferenceType.marketing.rawValue,
            action: "ENABLE"
        )
    ]

    public static let updatedPreferences = UpdatedPreferences(preferences: updatedPreferencesBundle)
}
