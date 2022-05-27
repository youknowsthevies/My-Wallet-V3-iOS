// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkError
import ToolKit

/// The `Combine` network adapter API, all new uses of networking should consume this API
public protocol NetworkAdapterAPI {

    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    /// - Returns: `Void` in case of success or `NetworkError` for failure
    func perform(request: NetworkRequest) -> AnyPublisher<Void, NetworkError>

    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    /// - Returns: `Void` on success or decodes the error
    ///              into a `FromNetworkErrorConvertible` conforming type.
    func perform<ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<Void, ErrorResponseType>

    /// Performs a request and maps the response or error response
    /// - Parameter request: the request to perform
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, ErrorResponseType>

    /// Performs a request and maps the response or error response
    /// - Parameter request: the request to perform
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            `NetworkError` for the error case.
    func perform<ResponseType: Decodable>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, NetworkError>

    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - responseType: the type of the response to map to
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType>

    /// Performs a request and maps the response and returns any errors
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - responseType: the type of the response to map to
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            `NetworkError` for the error case.
    func perform<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, NetworkError>

    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - errorResponseType: the type of the error response to map to
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType>

    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - responseType: the type of the response to map to
    ///   - errorResponseType: the type of the error response to map to
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType>

    /// Performs a request and if there is content maps the response and always maps the error type
    /// - Parameters:
    ///   - request: the request to perform
    ///   - responseType: the type of the response to map to
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func performOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType>

    /// Performs a request and if there is content maps the response and always maps the error type
    /// - Parameters:
    ///   - request: the request to perform
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func performOptional(
        request: NetworkRequest
    ) -> AnyPublisher<Void, NetworkError>

    /// Performs a request and if there is content maps the response and always maps the error type
    /// - Parameters:
    ///   - request: the request to perform
    ///   - responseType: the type of the response to map to
    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, NetworkError>

    /// Performs a request and if there is content maps the response and always maps the error type
    /// - Parameters:
    ///   - request: the request to perform
    ///   - responseType: the type of the response to map to
    ///   - errorResponseType: the type of the error response to map to
    func performOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType>

    func performWebsocket<ResponseType: Decodable>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, NetworkError>
}

extension NetworkAdapterAPI {
    public func perform(request: NetworkRequest) -> AnyPublisher<Void, NetworkError> {
        perform(request: request)
            .map { (_: EmptyNetworkResponse) -> Void in
                ()
            }
            .eraseToAnyPublisher()
    }

    public func perform<ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<Void, ErrorResponseType> {
        perform(request: request)
            .map { (_: EmptyNetworkResponse) -> Void in
                ()
            }
            .eraseToAnyPublisher()
    }

    public func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        perform(request: request)
    }

    public func perform<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, NetworkError> {
        perform(request: request)
    }

    public func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        perform(request: request)
    }

    public func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        perform(request: request)
    }

    public func performOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        performOptional(request: request, responseType: responseType)
    }

    public func performOptional(
        request: NetworkRequest
    ) -> AnyPublisher<Void, NetworkError> {
        perform(request: request, responseType: EmptyNetworkResponse.self)
            .mapToVoid()
    }
}
