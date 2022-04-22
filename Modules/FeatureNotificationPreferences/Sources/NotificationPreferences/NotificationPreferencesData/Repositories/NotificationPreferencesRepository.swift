//
//  File.swift
//  
//
//  Created by Augustin Udrea on 15/04/2022.
//

import Foundation
import FeatureNotificationPreferencesDomain
import Combine
import NetworkError

public struct NotificationPreferencesRepository: NotificationPreferencesRepositoryAPI {
    private let client: NotificationPreferencesClient

    public init(client: NotificationPreferencesClient) {
        self.client = client
    }

    public func fetchPreferences() -> AnyPublisher<[NotificationPreference], NetworkError> {
        client
            .fetchSettings()
            .map({ response in
                let availableMethods = response.notificationMethods
                
                return response
                    .preferences
                    .map{$0.toNotificationPreference(with: availableMethods)}
            })
            .eraseToAnyPublisher()
    }
    
    public func update(preferences: UpdatedPreferences) -> AnyPublisher<Void, NetworkError> {
        client
            .update(preferences)
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
                                      type: type,
                                      title: title,
                                      preferenceDescription: description,
                                      requiredMethods: requiredMethods,
                                      optionalMethods: optionalMethods,
                                      enabledMethods: enabledMethods)
    }
}
