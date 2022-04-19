//
//  File.swift
//  
//
//  Created by Augustin Udrea on 15/04/2022.
//

import Foundation
import FeatureNotificationSettingsDomain
import Combine
import NetworkError

public struct NotificationSettingsRepository: NotificationSettingsRepositoryAPI {

    private let client: NotificationsSettingsClient

    public init(client: NotificationsSettingsClient) {
        self.client = client
    }

    public func fetchSettings() -> AnyPublisher<[NotificationPreference], NetworkError> {
        client.fetchSettings()
            .map({ response in
                let availableMethods = response.notificationMethods
                
                return response
                    .preferences
                    .map{$0.toNotificationPreference(with: availableMethods)}
            })
            .eraseToAnyPublisher()
    }
}


extension NotificationMethodInfoResponse {
    public func toNotificationMethodInfo() -> NotificationMethodInfo {
        NotificationMethodInfo(id: UUID(), method: method, title: title, configured: configured, verified: verified)
    }
}

extension NotificationPreferenceResponse {
    public func toNotificationPreference(with availableMethods: [NotificationMethodInfoResponse]) -> NotificationPreference {
        
        let requiredMethods: [NotificationMethodInfo] = self
            .requiredMethods
            .compactMap({ currentMethod in
                return availableMethods.filter{ $0.method == currentMethod}.first?.toNotificationMethodInfo()
            })
        
        let optionalMethods: [NotificationMethodInfo] = self
            .optionalMethods
            .compactMap({ currentMethod in
                return availableMethods.filter{ $0.method == currentMethod}.first?.toNotificationMethodInfo()
            })

        let enabledMethods: [NotificationMethodInfo] = self
            .enabledMethods
            .compactMap({ currentMethod in
                return availableMethods.filter{ $0.method == currentMethod}.first?.toNotificationMethodInfo()
            })

        return NotificationPreference(id: UUID(),
                                      type: type, title: title, preferenceDescription: preferenceDescription,
                                      requiredMethods: requiredMethods,
                                      optionalMethods: optionalMethods,
                                      enabledMethods: enabledMethods)
    }
}
