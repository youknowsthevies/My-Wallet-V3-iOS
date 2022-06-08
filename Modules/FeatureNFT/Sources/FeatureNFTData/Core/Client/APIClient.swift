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

    func registerEmailForNFTViewWaitlist(
        _ email: String
    ) -> AnyPublisher<Void, NabuNetworkError>
}

public final class APIClient: FeatureNFTClientAPI {

    private enum Path {
        static let assets = [
            "explorer-gateway",
            "nft",
            "assets"
        ]
        static let waitlist = [
            "explorer-gateway",
            "features",
            "subscribe"
        ]
    }

    private enum Parameter {
        static let owner = "owner"
    }

    // MARK: - Private Properties

    private let retailRequestBuilder: RequestBuilder
    private let retailNetworkAdapter: NetworkAdapterAPI
    private let defaultRequestBuilder: RequestBuilder
    private let defaultNetworkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    public init(
        retailNetworkAdapter: NetworkAdapterAPI,
        defaultNetworkAdapter: NetworkAdapterAPI,
        retailRequestBuilder: RequestBuilder,
        defaultRequestBuilder: RequestBuilder
    ) {
        self.retailNetworkAdapter = retailNetworkAdapter
        self.retailRequestBuilder = retailRequestBuilder
        self.defaultNetworkAdapter = defaultNetworkAdapter
        self.defaultRequestBuilder = defaultRequestBuilder
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
        let request = retailRequestBuilder.post(
            path: Path.assets,
            parameters: parameters,
            contentType: .json
        )!
        return retailNetworkAdapter.perform(request: request)
    }

    public func registerEmailForNFTViewWaitlist(
        _ email: String
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let payload = ViewWaitlistRequest(email: email)
        let request = defaultRequestBuilder.post(
            path: Path.waitlist,
            body: try? JSONEncoder().encode(payload)
        )!
        return defaultNetworkAdapter.perform(request: request)
    }
}
