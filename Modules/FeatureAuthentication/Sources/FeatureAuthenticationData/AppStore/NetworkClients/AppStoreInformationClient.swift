// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit
import ToolKit

protocol AppStoreInformationClientAPI: AnyObject {

    func fetchAppStoreResponseForBundleId(
        _ bundleId: String
    ) -> AnyPublisher<AppStoreResponse, NetworkError>
}

final class AppStoreInformationClient: AppStoreInformationClientAPI {

    private enum Endpoint {
        static let scheme = "https"
        static let host = "itunes.apple.com"
        static let path: String = "/lookup"

        enum Paramter {
            static let bundleId: String = "bundleId"
        }
    }

    private let networkAdapter: NetworkAdapterAPI

    init(networkAdapter: NetworkAdapterAPI = DIKit.resolve()) {
        self.networkAdapter = networkAdapter
    }

    // MARK: - AppStoreInformationClientAPI

    func fetchAppStoreResponseForBundleId(
        _ bundleId: String
    ) -> AnyPublisher<AppStoreResponse, NetworkError> {
        let parameters: [URLQueryItem] = [
            URLQueryItem(
                name: Endpoint.Paramter.bundleId,
                value: bundleId
            )
        ]
        var components = URLComponents()
        components.queryItems = parameters
        components.scheme = Endpoint.scheme
        components.host = Endpoint.host
        components.path = Endpoint.path

        let url = components.url!
        let request: NetworkRequest = NetworkRequest(
            endpoint: url,
            method: .get
        )
        return networkAdapter.perform(request: request)
    }
}
