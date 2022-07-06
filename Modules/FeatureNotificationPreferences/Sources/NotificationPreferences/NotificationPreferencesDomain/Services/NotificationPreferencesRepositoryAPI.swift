// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol NotificationPreferencesRepositoryAPI {
    func fetchPreferences() -> AnyPublisher<[NotificationPreference], NetworkError>
    func update(preferences: UpdatedPreferences) -> AnyPublisher<Void, NetworkError>
}
