// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit
import WalletPayloadKit

public final class TwoFAWalletClient: TwoFAWalletClientAPI {

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: TwoFARequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = TwoFARequestBuilder(requestBuilder: requestBuilder)
    }

    // MARK: - API

    public func payload(
        guid: String,
        sessionToken: String,
        code: String
    ) -> AnyPublisher<WalletPayloadWrapper, NetworkError> {
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
            .eraseToAnyPublisher()
    }
}

// MARK: - TwoFAWalletClient

extension TwoFAWalletClient {

    private struct TwoFARequestBuilder {

        private let pathComponents = ["wallet"]

        private enum Parameters {
            static let method = "method"
            static let guid = "guid"
            static let payload = "payload"
            static let length = "length"
            static let format = "format"
            static let apiCode = "apiCode"
        }

        private enum HeaderKey: String {
            case authorization = "Authorization"
        }

        // MARK: - Builder

        private let requestBuilder: RequestBuilder

        init(requestBuilder: RequestBuilder) {
            self.requestBuilder = requestBuilder
        }

        // MARK: - API

        func build(guid: String, sessionToken: String, code: String) -> NetworkRequest {
            let headers = [HeaderKey.authorization.rawValue: "Bearer \(sessionToken)"]
            let parameters = [
                URLQueryItem(
                    name: Parameters.method,
                    value: "get-wallet"
                ),
                URLQueryItem(
                    name: Parameters.guid,
                    value: guid
                ),
                URLQueryItem(
                    name: Parameters.payload,
                    value: code
                ),
                URLQueryItem(
                    name: Parameters.length,
                    value: String(code.count)
                ),
                URLQueryItem(
                    name: Parameters.format,
                    value: "plain"
                ),
                URLQueryItem(
                    name: Parameters.apiCode,
                    value: "api_code"
                )
            ]
            let data = RequestBuilder.body(from: parameters)
            return requestBuilder.post(
                path: pathComponents,
                body: data,
                headers: headers,
                contentType: .formUrlEncoded
            )!
        }
    }
}
