//
//  File.swift
//  
//
//  Created by Augustin Udrea on 21/04/2022.
//

import Foundation
import FeatureNotificationPreferencesDomain
import FeatureNotificationPreferencesData
import Combine
import NetworkError

class NotificationPreferencesRepositoryMock: NotificationPreferencesRepositoryAPI {
    // MARK: - Mock Properties
    var fetchSettingsCalled = false
    func fetchSettings() -> AnyPublisher<[NotificationPreference], NetworkError> {
        fetchSettingsCalled = true
        return .just([MockGenerator.securityNotificationPreference])
    }
}


class UpdateContactPreferencesServiceMock: UpdateContactPreferencesServiceAPI {
    func update(_ preferences: [UpdatedNotificationPreference] ) -> AnyPublisher<Void, NabuNetworkError> {
        return .just(())
    }
}
