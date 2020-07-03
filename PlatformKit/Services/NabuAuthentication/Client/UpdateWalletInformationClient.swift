//
//  UpdateWalletInformationClient.swift
//  PlatformKit
//
//  Created by Daniel on 29/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public protocol UpdateWalletInformationClientAPI: AnyObject {
    func updateWalletInfo(jwtToken: String) -> Completable
}

public final class UpdateWalletInformationClient: UpdateWalletInformationClientAPI {
     
    private enum Path {
        static let updateWalletInfo = [ "users", "current", "walletInfo" ]
    }
     
    // MARK: - Properties
     
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

     // MARK: - Setup
      
    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
     
    }
         
    public func updateWalletInfo(jwtToken: String) -> Completable {
        let payload = JWTPayload(jwt: jwtToken)
        let request = requestBuilder.put(
            path: Path.updateWalletInfo,
            body: try? payload.encode(),
            authenticated: true
        )!
        return communicator.perform(request: request)
     }
}
