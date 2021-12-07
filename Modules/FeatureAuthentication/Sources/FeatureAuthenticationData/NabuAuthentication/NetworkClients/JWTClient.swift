// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit

protocol JWTClientAPI: AnyObject {
    func requestJWT(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<String, JWTClient.ClientError>
}

final class JWTClient: JWTClientAPI {

    // MARK: - Types

    enum ClientError: Error {
        case jwt(String)
    }

    private struct JWTResponse: Decodable {
        let success: Bool
        let token: String?
        let error: String?
    }

    private enum Path {
        static let wallet = ["wallet"]
    }

    private enum Parameter {
        static let method = "method"
        static let guid = "guid"
        static let sharedKey = "sharedKey"
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func requestJWT(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<String, JWTClient.ClientError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.method,
                value: "signed-retail-token"
            ),
            URLQueryItem(
                name: Parameter.guid,
                value: guid
            ),
            URLQueryItem(
                name: Parameter.sharedKey,
                value: sharedKey
            )
        ]
        let data = RequestBuilder.body(from: parameters)
        let request = requestBuilder.post(
            path: Path.wallet,
            body: data,
            contentType: .formUrlEncoded
        )!
        return networkAdapter.perform(request: request)
            .mapError { (networkError: NetworkError) -> JWTClient.ClientError in
                .jwt(String(describing: networkError))
            }
            .flatMap { (response: JWTResponse) -> AnyPublisher<String, JWTClient.ClientError> in
                guard response.success else {
                    return .failure(ClientError.jwt(response.error ?? ""))
                }
                guard let token = response.token else {
                    return .failure(ClientError.jwt(response.error ?? ""))
                }
                return .just(token)
            }
            .eraseToAnyPublisher()
    }
}
