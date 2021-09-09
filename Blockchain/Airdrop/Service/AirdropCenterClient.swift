// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NabuNetworkError
import NetworkKit
import PlatformKit

protocol AirdropCenterClientAPI: AnyObject {
    var campaigns: AnyPublisher<AirdropCampaigns, NabuNetworkError> { get }
}

// TODO: Move into `PlatformKit` when IOS-2724 is merged
final class AirdropCenterClient: AirdropCenterClientAPI {

    // MARK: - Properties

    var campaigns: AnyPublisher<AirdropCampaigns, NabuNetworkError> {
        let request = requestBuilder.get(
            path: pathComponents,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    private let pathComponents = ["users", "user-campaigns"]
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
}
