//
//  File.swift
//  
//
//  Created by Augustin Udrea on 15/04/2022.
//

import Foundation
import Combine
import NetworkKit
import NetworkError
import DIKit
import NabuNetworkError


public protocol ContactLanguagePreferenceServiceAPI: AnyObject {
    func updateLanguage(
        language: String
    ) -> AnyPublisher<Void, NabuNetworkError>
}

final class ContactLanguagePreferenceService: ContactLanguagePreferenceServiceAPI {
    private enum Path {
        static let updateLanguagePreferenceInfo = ["users", "current", "lang"]
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

    func updateLanguage(
        language: String
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let payload = ContactLanguagePreferenceDTO(language: language)
        let request = requestBuilder.put(
            path: Path.updateLanguagePreferenceInfo,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
