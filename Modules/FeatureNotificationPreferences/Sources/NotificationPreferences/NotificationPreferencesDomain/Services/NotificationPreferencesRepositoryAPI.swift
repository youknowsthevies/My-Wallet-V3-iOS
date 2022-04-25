// Copyright © Blockchain Luxembourg S.A. All rights reserved.


import Foundation
import NetworkError
import Combine

public protocol NotificationPreferencesRepositoryAPI {
    func fetchPreferences() -> AnyPublisher<[NotificationPreference], NetworkError>
    func update(preferences: UpdatedPreferences) -> AnyPublisher<Void, NetworkError>
}
