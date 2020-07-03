//
//  AirdropCenterClient.swift
//  Blockchain
//
//  Created by Daniel Huri on 27/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import PlatformKit
import RxSwift

protocol AirdropCenterClientAPI: class {
    var campaigns: Single<AirdropCampaigns> { get }
}

/// TODO: Move into `PlatformKit` when https://blockchain.atlassian.net/browse/IOS-2724 is merged
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
        return communicator.perform(request: request)
    }
    
    private let pathComponents = [ "users", "user-campaigns" ]
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI
    
    // MARK: - Setup
    
    init(dependencies: Network.Dependencies = .retail) {
        communicator = dependencies.communicator
        requestBuilder = dependencies.requestBuilder
    }
}
