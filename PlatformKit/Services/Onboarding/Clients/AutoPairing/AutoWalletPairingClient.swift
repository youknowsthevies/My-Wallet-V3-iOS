//
//  AutoWalletPairingClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 10/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public final class AutoWalletPairingClient: AutoWalletPairingClientAPI {
            
    // MARK: - Properties
    
    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder: RequestBuilder
    
    // MARK: - Setup

    public init(dependencies: Network.Dependencies = .wallet) {
        self.requestBuilder = RequestBuilder(requestBuilder: dependencies.requestBuilder)
        self.communicator = dependencies.communicator
    }
        
    public func request(guid: String) -> Single<String> {
        let request = requestBuilder.build(guid: guid)
        return communicator
            .perform(request: request, responseType: RawServerResponse.self)
            .map { $0.data }
    }
}

// MARK: - Request Builder

extension AutoWalletPairingClient {
    
    private struct RequestBuilder {
        
        // MARK: - Types
        
        private let pathComponents = [ "wallet" ]
        
        private struct Payload: Encodable {
            let guid: String
            let method = "pairing-encryption-password"
            let apiCode = "api_code"
        }
        
        // MARK: - Builder
        
        private let requestBuilder: NetworkKit.RequestBuilder

        // MARK: - Setup
        
        init(requestBuilder: NetworkKit.RequestBuilder) {
            self.requestBuilder = requestBuilder
        }
        
        // MARK: - API
        
        func build(guid: String) -> NetworkRequest {
            let payload = Payload(guid: guid)
            let body = ParameterEncoder(payload.dictionary).encoded!
            return requestBuilder.post(
                path: pathComponents,
                body: body,
                contentType: .formUrlEncoded
            )!
        }
    }
}
