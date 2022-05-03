// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureNotificationPreferencesDomain
import NetworkError
import NetworkKit

public protocol NotificationPreferencesClientAPI {
    func fetchPreferences() -> AnyPublisher<NotificationInfoResponse, NetworkError>
    func update(_ preferences: UpdatedPreferences) -> AnyPublisher<Void, NetworkError>
}

public struct NotificationPreferencesClient: NotificationPreferencesClientAPI {
    // MARK: - Private Properties

    private enum Path {
        static let contactPreferences = ["users", "contact-preferences"]
    }

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func fetchPreferences() -> AnyPublisher<NotificationInfoResponse, NetworkError> {
        let request = requestBuilder.get(
            path: Path.contactPreferences,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    public func update(_ preferences: UpdatedPreferences) -> AnyPublisher<Void, NetworkError> {
        let request = requestBuilder.put(
            path: Path.contactPreferences,
            body: try? preferences.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
