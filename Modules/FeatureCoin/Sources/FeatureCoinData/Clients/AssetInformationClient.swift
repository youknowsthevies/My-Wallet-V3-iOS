// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCoinDomain
import Foundation
import NetworkError
import NetworkKit

public protocol AssetInformationClientAPI {

    func fetchInfo(
        _ currencyCode: String
    ) -> AnyPublisher<AssetInformation, NetworkError>
}

public final class AssetInformationClient: AssetInformationClientAPI {

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func fetchInfo(
        _ currencyCode: String
    ) -> AnyPublisher<AssetInformation, NetworkError> {
        networkAdapter.perform(request: requestBuilder.get(path: "/assets/info/\(currencyCode)")!)
    }
}
