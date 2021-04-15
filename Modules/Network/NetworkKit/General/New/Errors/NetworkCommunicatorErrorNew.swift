//
//  NetworkCommunicatorErrorNew.swift
//  NetworkKit
//
//  Created by Jack Pooley on 25/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import ToolKit

/// A networking error returned by the network layer, this can be mapped to user facing errors at a high level
public enum NetworkCommunicatorErrorNew: Error {
    case urlError(URLError)
    case serverError(HTTPRequestServerErrorNew)
    case rawServerError(ServerErrorResponseNew)
    case payloadError(HTTPRequestPayloadErrorNew)
    case authentication(Error)
    
    func analyticsEvent(
        for request: NetworkRequest,
        decodeErrorResponse: ((ServerErrorResponseNew) -> String?)? = nil
    ) -> AnalyticsEvent? {
        switch self {
        case .urlError(let urlError):
            return NetworkErrorEvent(request: request, error: urlError)
        case .rawServerError, .serverError, .payloadError, .authentication:
            return APIErrorEvent(
                request: request,
                error: self,
                decodeErrorResponse: decodeErrorResponse
            )
        }
    }
}

extension NetworkCommunicatorErrorNew {
    
    public var legacyError: NetworkCommunicatorError {
        switch self {
        case .urlError(let urlError):
            return .unknown(urlError)
        case .serverError(let httpServerError):
            return .serverError(httpServerError.legacyError)
        case .rawServerError(let rawServerError):
            return .rawServerError(rawServerError.legacyError)
        case .payloadError(let payloadError):
            return .payloadError(payloadError.legacyError)
        case .authentication(let authenticationError):
            return .unknown(authenticationError)
        }
    }
}

/// Errors returned when there is an unexpected response or invalid status code
public enum HTTPRequestServerErrorNew: Error {
    case badResponse
    case badStatusCode(code: Int, error: Error?, message: String?)
    
    public var code: Int? {
        switch self {
        case .badResponse:
            return nil
        case .badStatusCode(code: let code, _, _):
            return code
        }
    }
}

extension HTTPRequestServerErrorNew {
    
    public var legacyError: HTTPRequestServerError {
        switch self {
        case .badResponse:
            return .badResponse
        case .badStatusCode(let code, let error, let message):
            return .badStatusCode(code: code, error: error, message: message)
        }
    }
}

/// Errors to represent invalid or empty payload errors
public enum HTTPRequestPayloadErrorNew: Error {
    case emptyData
    case badData(rawPayload: String)
}

extension HTTPRequestPayloadErrorNew {
    
    public var legacyError: HTTPRequestPayloadError {
        switch self {
        case .emptyData:
            return .emptyData
        case .badData(let rawPayload):
            return .badData(rawPayload: rawPayload)
        }
    }
}

extension AnyPublisher where Output: Decodable, Failure == NetworkCommunicatorErrorNew {
    
    public func mapToLegacyError() -> AnyPublisher<Output, NetworkCommunicatorError> {
        mapError(\.legacyError)
            .eraseToAnyPublisher()
    }
}
