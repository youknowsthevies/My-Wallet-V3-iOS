// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit

protocol ServerEntropyClientAPI {
    func getEntropy(request: EntropyRequest) -> AnyPublisher<String, NetworkError>
}

final class ServerEntropyClient: ServerEntropyClientAPI {
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func getEntropy(request: EntropyRequest) -> AnyPublisher<String, NetworkError> {
        let request = requestBuilder.get(
            path: ["v2", "randombytes"],
            parameters: request.parameters
        )!
        return networkAdapter.perform(request: request)
    }
}
