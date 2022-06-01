// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureNFTDomain
import Foundation
import NetworkKit
import ToolKit

public protocol FeatureNFTClientAPI {
    func fetchAssetsFromEthereumAddress(
        _ address: String
    ) -> AnyPublisher<[AssetResponse], NabuNetworkError>
}

public final class APIClient: FeatureNFTClientAPI {

    private enum Path {
        static let assets = [
            "explorer-gateway",
            "nft",
            "assets"
        ]
    }

    private enum Parameter {
        static let owner = "owner"
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - FeatureNFTClientAPI

    public func fetchAssetsFromEthereumAddress(
        _ address: String
    ) -> AnyPublisher<[AssetResponse], NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.owner,
                value: address
            )
        ]
        let request = requestBuilder.post(
            path: Path.assets,
            parameters: parameters,
            contentType: .json
        )!
        return networkAdapter.perform(request: request)
    }
}
