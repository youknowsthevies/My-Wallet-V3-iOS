//
//  TwoFAWalletClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 21/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift
import WalletPayloadKit

public final class TwoFAWalletClient: TwoFAWalletClientAPI {

    /// Potential errors.
    /// Possiblly there are more than one error, but only one is known
    /// at the moment.
    enum ClientError: Error {
        
        private struct RawErrorSubstring {
            static let accountLocked = "locked"
            static let wrongCode = "attempts left"
        }
        
        /// Wrong code
        case wrongCode(attemptsLeft: Int)
        
        // Account locked
        case accountLocked
        
        /// Initialized with plain server error
        init?(plainServerError: String) {
            if plainServerError.contains(RawErrorSubstring.accountLocked) {
                self = .accountLocked
            } else if plainServerError.contains(RawErrorSubstring.wrongCode) {
                let attemptsLeftString = plainServerError.components(
                    separatedBy: CharacterSet.decimalDigits.inverted
                ).joined()
                guard let attemptsLeft = Int(attemptsLeftString) else {
                    return nil
                }
                self = .wrongCode(attemptsLeft: attemptsLeft)
            } else {
                return nil
            }
        }
    }
        
    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: TwoFARequestBuilder

    // MARK: - Setup
    
    public init(networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
                requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = TwoFARequestBuilder(requestBuilder: requestBuilder)
    }
    
    // MARK: - API
    
    public func payload(guid: String,
                        sessionToken: String,
                        code: String) -> Single<WalletPayloadWrapper> {
        let request = requestBuilder.build(
            guid: guid,
            sessionToken: sessionToken,
            code: code
        )
        return networkAdapter
            .perform(
                request: request,
                responseType: WalletPayloadWrapper.self
            )
            .catchError { error -> Single<WalletPayloadWrapper> in
                guard let communicatorError = error as? NetworkError else {
                    throw error
                }
                switch communicatorError {
                case .payloadError(.badData(rawPayload: let payload)):
                    throw ClientError(plainServerError: payload) ?? error
                default:
                    throw error
                }
            }
    }
}

// MARK: - TwoFAWalletClient

extension TwoFAWalletClient {
    
    private struct TwoFARequestBuilder {
        
        private let pathComponents = [ "wallet" ]
        
        private enum HeaderKey: String {
            case authorization = "Authorization"
        }
        
        private struct Payload: Encodable {
            let method = "get-wallet"
            let guid: String
            let payload: String
            let length: Int
            let format = "plain"
            let apiCode = "api_code"
            
            init(guid: String, payload: String) {
                self.guid = guid
                self.payload = payload
                self.length = payload.count
            }
        }
        
        // MARK: - Builder
        
        private let requestBuilder: RequestBuilder

        init(requestBuilder: RequestBuilder) {
            self.requestBuilder = requestBuilder
        }
        
        // MARK: - API
        
        func build(guid: String, sessionToken: String, code: String) -> NetworkRequest {
            let headers = [HeaderKey.authorization.rawValue: "Bearer \(sessionToken)"]
            let body = self.body(from: guid, code: code)
            return requestBuilder.post(
                path: pathComponents,
                body: body,
                headers: headers,
                contentType: .formUrlEncoded
            )!
        }
        
        private func body(from guid: String, code: String) -> Data! {
            let payload = Payload(guid: guid, payload: code)
            let data = ParameterEncoder(payload.dictionary).encoded!
            return data
        }
    }
}
