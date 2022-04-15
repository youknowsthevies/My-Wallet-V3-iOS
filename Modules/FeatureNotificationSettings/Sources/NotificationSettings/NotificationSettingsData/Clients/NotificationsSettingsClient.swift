//
//  File.swift
//  
//
//  Created by Augustin Udrea on 15/04/2022.
//

import Combine
import NetworkError
import NetworkKit

public protocol NotificationsSettingsClientAPI {
    func fetchSettings() -> AnyPublisher<NotificationInfoResponse, NetworkError>
}

public struct NotificationsSettingsClient: NotificationsSettingsClientAPI {
    // MARK: - Private Properties

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

    public func fetchSettings() -> AnyPublisher<NotificationInfoResponse, NetworkError> {
        let request = requestBuilder.get(
            path: "/users/contact-preferences",
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }
}

