//
//  AutoWalletPairingClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 10/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift

public final class AutoWalletPairingClient: AutoWalletPairingClientAPI {
            
    // MARK: - Properties
    
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: AutoWalletPairingClientRequestBuilder
    
    // MARK: - Setup
    
    public init(networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
                requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = AutoWalletPairingClientRequestBuilder(requestBuilder: requestBuilder)
    }
        
    public func request(guid: String) -> Single<String> {
        let request = requestBuilder.build(guid: guid)
        return networkAdapter
            .perform(request: request, responseType: RawServerResponse.self)
            .map { $0.data }
    }
}

// MARK: - Request Builder

extension AutoWalletPairingClient {
    
    private struct AutoWalletPairingClientRequestBuilder {
        
        // MARK: - Types
        
        private let pathComponents = [ "wallet" ]
        
        private struct Payload: Encodable {
            let guid: String
            let method = "pairing-encryption-password"
        }
        
        // MARK: - Builder
        
        private let requestBuilder: RequestBuilder

        // MARK: - Setup
        
        init(requestBuilder: RequestBuilder) {
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
