// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureNotificationPreferencesData
import FeatureNotificationPreferencesDomain
import Foundation
import FeatureNotificationPreferencesMocks
import NabuNetworkError
import NetworkError

class NotificationPreferencesRepositoryMock: NotificationPreferencesRepositoryAPI {
    // MARK: - Mock Properties

    var fetchSettingsCalled = false
    var updateCalled = false

    var fetchPreferencesSubject = CurrentValueSubject<[NotificationPreference], NetworkError>([])

    func fetchPreferences() -> AnyPublisher<[NotificationPreference], NetworkError> {
        fetchSettingsCalled = true
        return fetchPreferencesSubject.eraseToAnyPublisher()
    }

    func update(preferences: UpdatedPreferences) -> AnyPublisher<Void, NetworkError> {
        updateCalled = true
        return .just(())
    }
}
