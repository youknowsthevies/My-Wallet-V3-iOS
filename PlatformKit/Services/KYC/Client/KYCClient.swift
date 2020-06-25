//
//  UserClient.swift
//  Blockchain
//
//  Created by Daniel Huri on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import RxSwift

public final class KYCClient: KYCClientAPI {
    
    // MARK: - Types
    
    private enum Path {
        static let tiers = ["kyc", "tiers"]
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI
    
    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
    
    public func tiers(with token: String) -> Single<KYC.UserTiers> {
        let headers = [HttpHeaderField.authorization: token]
        let request = requestBuilder.get(
            path: Path.tiers,
            headers: headers
        )!
        return communicator.perform(request: request)
    }
}
