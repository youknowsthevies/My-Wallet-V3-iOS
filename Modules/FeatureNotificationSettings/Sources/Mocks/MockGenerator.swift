//
//  MockGenerator.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 12/04/2022.
//

import Foundation
import FeatureNotificationSettingsDomain
import Combine
import NetworkError

public struct MockGenerator {
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
        preferenceDescription: "Sent when a particular asset increases or decreases in price",
        requiredMethods: requiredMethods,
        optionalMethods: optionalMethods,
        enabledMethods: enabledMethods
    )

    public static let transactionalNotificationPreference = NotificationPreference(
        id: UUID(),
        type: .transactional,
        title: "Transactional notifications",
        preferenceDescription: "Sent when a particular asset increases or decreases in price",
        requiredMethods: requiredMethods,
        optionalMethods: optionalMethods,
        enabledMethods: enabledMethods
    )

    public static let securityNotificationPreference = NotificationPreference(
        id: UUID(),
        type: .security,
        title: "Security notifications",
        preferenceDescription: "Sent when a particular asset increases or decreases in price",
        requiredMethods: requiredMethods,
        optionalMethods: optionalMethods,
        enabledMethods: enabledMethods
    )

    public static let marketingNotificationPreference = NotificationPreference(
        id: UUID(),
        type: .marketing,
        title: "Marketing notifications",
        preferenceDescription: "Sent when a particular asset increases or decreases in price",
        requiredMethods: requiredMethods,
        optionalMethods: optionalMethods,
        enabledMethods: enabledMethods
    )
}

public class NotificationSettingsRepositoryMock: NotificationSettingsRepositoryAPI {
    var subject = PassthroughSubject<[NotificationPreference], NetworkError>()
    public init() {}
    public func fetchSettings() -> AnyPublisher<[NotificationPreference], NetworkError> {
        return subject.eraseToAnyPublisher()
    }
}

