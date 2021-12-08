// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MetadataKit
import NetworkKit

protocol MetadataClientAPI {

    func get(address: String) -> AnyPublisher<MetadataResponse, NetworkError>

    func put(payload: MetadataBody, at address: String) -> AnyPublisher<Void, NetworkError>
}

final class MetadataClient: MetadataClientAPI {

    private enum Path {

        static var basePath: [String] = ["metadata"]

        static func get(at address: String) -> [String] {
            basePath + [address]
        }

        static func put(at address: String) -> [String] {
            basePath + [address]
        }
    }

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func get(address: String) -> AnyPublisher<MetadataResponse, NetworkError> {
        let request = requestBuilder.get(
            path: Path.get(at: address)
        )!
        return networkAdapter.perform(request: request)
    }

    func put(payload: MetadataBody, at address: String) -> AnyPublisher<Void, NetworkError> {
        // swiftlint:disable force_try
        let request = requestBuilder.put(
            path: Path.put(at: address),
            body: try! JSONEncoder().encode(payload.request)
        )!
        return networkAdapter.perform(request: request)
    }
}
