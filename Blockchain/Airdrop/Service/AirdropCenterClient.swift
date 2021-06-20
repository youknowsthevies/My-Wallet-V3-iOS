// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import PlatformKit
import RxSwift

protocol AirdropCenterClientAPI: AnyObject {
    var campaigns: Single<AirdropCampaigns> { get }
}

/// TODO: Move into `PlatformKit` when IOS-2724 is merged
final class AirdropCenterClient: AirdropCenterClientAPI {

    // MARK: - Properties

    var campaigns: Single<AirdropCampaigns> {
        let endpoint = URL.endpoint(
            URL(string: BlockchainAPI.shared.retailCoreUrl)!,
            pathComponents: pathComponents,
            queryParameters: nil
        )!
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .get,
            authenticated: true
        )
        return networkAdapter.perform(
            request: request,
            errorResponseType: NabuNetworkError.self
        )
    }

    private let pathComponents = [ "users", "user-campaigns" ]
    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
         requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }
}
