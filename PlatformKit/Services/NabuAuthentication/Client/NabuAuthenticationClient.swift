//
//  NabuAuthenticationClient.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public protocol NabuAuthenticationClientAPI: AnyObject {
    func sessionToken(for guid: String,
                      userToken: String,
                      userIdentifier: String,
                      deviceId: String,
                      email: String) -> Single<NabuSessionTokenResponse>
}

public final class NabuAuthenticationClient: NabuAuthenticationClientAPI {
    
    // MARK: - Types
    
    private enum Parameter: String {
        case userId
    }
    
    private enum Path {
        static let auth = [ "auth" ]
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
        
    public func sessionToken(for guid: String,
                             userToken: String,
                             userIdentifier: String,
                             deviceId: String,
                             email: String) -> Single<NabuSessionTokenResponse> {
        
        let headers: [String: String] = [
            HttpHeaderField.appVersion: Bundle.applicationVersion ?? "",
            HttpHeaderField.clientType: HttpHeaderValue.clientTypeApp,
            HttpHeaderField.deviceId: deviceId,
            HttpHeaderField.authorization: userToken,
            HttpHeaderField.walletGuid: guid,
            HttpHeaderField.walletEmail: email
        ]
        
        let parameters = [
            URLQueryItem(
                name: Parameter.userId.rawValue,
                value: userIdentifier
            )
        ]

        let request = requestBuilder.post(
            path: Path.auth,
            parameters: parameters,
            headers: headers
        )!
        return communicator.perform(request: request)
    }
}

