//
//  UpdateWalletInformationClient.swift
//  PlatformKit
//
//  Created by Daniel on 29/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import NetworkKit

public protocol UpdateWalletInformationClientAPI: AnyObject {
    func updateWalletInfo(jwtToken: String) -> Completable
}

final class UpdateWalletInformationClient: UpdateWalletInformationClientAPI {
     
    private enum Path {
        static let updateWalletInfo = [ "users", "current", "walletInfo" ]
    }
     
    // MARK: - Properties
     
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

     // MARK: - Setup
      
    init(communicator: NetworkCommunicatorAPI = resolve(tag: DIKitContext.retail),
         requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)) {
        self.communicator = communicator
        self.requestBuilder = requestBuilder
    }
         
    func updateWalletInfo(jwtToken: String) -> Completable {
        let payload = JWTPayload(jwt: jwtToken)
        let request = requestBuilder.put(
            path: Path.updateWalletInfo,
            body: try? payload.encode(),
            authenticated: true
        )!
        return communicator.perform(request: request)
     }
}
