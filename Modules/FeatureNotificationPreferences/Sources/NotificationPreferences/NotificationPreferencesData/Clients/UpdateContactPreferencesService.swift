//
//  File.swift
//  
//
//  Created by Augustin Udrea on 21/04/2022.
//

import Foundation

final class UpdateContactPreferencesService: UpdateContactPreferencesServiceAPI {
    private enum Path {
        static let updateLanguagePreferenceInfo = ["users", "contact-preferences"]
    }

    // MARK: - Properties
    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func update(_ preferences: [UpdatedNotificationPreference]
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let request = requestBuilder.put(
            path: Path.updateLanguagePreferenceInfo,
            body: try? preferences.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}

