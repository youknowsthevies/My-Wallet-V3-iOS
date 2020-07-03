//
//  JWTClient.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public protocol JWTClientAPI: AnyObject {
    func requestJWT(guid: String, sharedKey: String) -> Single<String>
}

public final class JWTClient: JWTClientAPI {

    // MARK: - Types
    
    private enum ClientError: Error {
        case jwt(String)
    }
    
    private struct JWTResponse: Decodable {
        let success: Bool
        let token: String?
        let error: String?
    }
    
    private enum Path {
        static let token = [ "wallet", "signed-retail-token" ]
    }
    
    private enum Parameter {
        static let guid = "guid"
        static let sharedKey = "sharedKey"
        static let apiCode = "api_code"
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .wallet) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
    
    public func requestJWT(guid: String, sharedKey: String) -> Single<String> {
        let queryParameters = [
            URLQueryItem(
                name: Parameter.guid,
                value: guid
            ),
            URLQueryItem(
                name: Parameter.sharedKey,
                value: sharedKey
            ),
            URLQueryItem(
                name: Parameter.apiCode,
                value: BlockchainAPI.Parameters.apiCode
            )
        ]
        let request = requestBuilder.get(
            path: Path.token,
            parameters: queryParameters
        )!
        return communicator.perform(request: request)
            .map { (response: JWTResponse) -> String in
                guard response.success else { throw ClientError.jwt(response.error ?? "") }
                guard let token = response.token else { throw ClientError.jwt(response.error ?? "") }
                return token
            }
    }
}
