// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkError

public protocol NotificationPreferencesRepositoryAPI {
    func fetchPreferences() -> AnyPublisher<[NotificationPreference], NetworkError>
    func update(preferences: UpdatedPreferences) -> AnyPublisher<Void, NetworkError>
}
