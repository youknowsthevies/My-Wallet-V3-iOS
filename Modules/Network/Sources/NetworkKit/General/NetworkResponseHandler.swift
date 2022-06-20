// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkError
import ToolKit

public protocol NetworkResponseHandlerAPI {

    /// Performs handling on the `data` and `response` returned by the network request
    /// - Parameters:
    ///   - elements: the `data` and `response` to handle
    ///   - request: the request corresponding to this response
    func handle(
        elements: (data: Data, response: URLResponse),
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError>

    func handle(
        message: URLSessionWebSocketTask.Message,
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError>
}

public final class NetworkResponseHandler: NetworkResponseHandlerAPI {

    public init() {}

    public func handle(
        elements: (data: Data, response: URLResponse),
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        handler(elements: elements, for: request)
            .publisher
            .eraseToAnyPublisher()
    }

    public func handle(
        message: URLSessionWebSocketTask.Message,
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        handler(message: message)
            .publisher
            .eraseToAnyPublisher()
    }

    private func handler(
        message: URLSessionWebSocketTask.Message
    ) -> Result<ServerResponse, NetworkError> {
        switch message {

        case .data(let data):
            let response = ServerResponse(
                payload: data,
                response: nil
            )
            return .success(response)

        case .string(let string):
            let response = ServerResponse(
                payload: Data(string.utf8),
                response: nil
            )
            return .success(response)

        default:
            return .failure(.payloadError(.emptyData))
        }
    }

    // MARK: - Private methods

    private func handler(
        elements: (data: Data, response: URLResponse),
        for request: NetworkRequest
    ) -> Result<ServerResponse, NetworkError> {
        Result<(data: Data, response: URLResponse), NetworkError>.success(elements)
            .flatMap { elements -> Result<ServerResponse, NetworkError> in
                guard let response = elements.response as? HTTPURLResponse else {
                    return .failure(.serverError(.badResponse))
                }
                let payload = elements.data
                switch response.statusCode {

                case 204:
                    request.peek("🌎 📲", \.endpoint, if: \.isDebugging.response)
                    return .success(ServerResponse(payload: nil, response: response))
                case 200...299:
                    request.peek("🌎 📲 Data(count: \(payload.count))", \.endpoint, if: \.isDebugging.response)
                    return .success(ServerResponse(payload: payload, response: response))
                default:
                    request.peek("🌎 ‼️ \(response.statusCode)", \.endpoint)
                    return .failure(
                        .rawServerError(
                            ServerErrorResponse(response: response, payload: payload)
                        )
                    )
                }
            }
    }
}
