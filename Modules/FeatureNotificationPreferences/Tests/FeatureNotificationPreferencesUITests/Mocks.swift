// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import FeatureNotificationPreferencesDomain
import FeatureNotificationPreferencesData
import Combine
import NetworkError
import NabuNetworkError
import Mocks

class NotificationPreferencesRepositoryMock: NotificationPreferencesRepositoryAPI {
    // MARK: - Mock Properties
    var fetchSettingsCalled = false
    var updateCalled = false
    
    var fetchPreferencesSubject = CurrentValueSubject<[NotificationPreference],NetworkError>([])
    
    func fetchPreferences() -> AnyPublisher<[NotificationPreference], NetworkError> {
        fetchSettingsCalled = true
        return fetchPreferencesSubject.eraseToAnyPublisher()
    }
    
    func update(preferences: UpdatedPreferences) -> AnyPublisher<Void, NetworkError> {
        updateCalled = true
        return .just(())
    }
}
