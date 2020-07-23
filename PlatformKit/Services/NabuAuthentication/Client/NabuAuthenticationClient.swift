//
//  NabuAuthenticationClient.swift
//  Blockchain
//
//  Created by Daniel Huri on 13/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift

public protocol NabuAuthenticationClientAPI: AnyObject {
    func sessionToken(for guid: String,
                      userToken: String,
                      userIdentifier: String,
                      deviceId: String,
                      email: String) -> Single<NabuSessionTokenResponse>
    
    func recoverUser(offlineToken: NabuOfflineTokenResponse, jwt: String) -> Completable
}

final class NabuAuthenticationClient: NabuAuthenticationClientAPI {
    
    // MARK: - Types
    
    private enum Parameter: String {
        case userId
    }
    
    private enum Path {
        static let auth = [ "auth" ]
        
        static func recover(userId: String) -> [String] {
            [ "users", "recover", userId ]
        }
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
        
    func sessionToken(for guid: String,
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
    
    func recoverUser(offlineToken: NabuOfflineTokenResponse, jwt: String) -> Completable {
        let request = requestBuilder.post(
            path: Path.recover(userId: offlineToken.userId),
            body: try? JWTPayload(jwt: jwt).encode(),
            headers: [HttpHeaderField.authorization: "Bearer \(offlineToken.token)"]
        )!
        return communicator.perform(request: request)
    }
}

