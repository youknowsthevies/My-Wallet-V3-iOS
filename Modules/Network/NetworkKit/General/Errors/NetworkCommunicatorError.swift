//
//  NetworkCommunicatorError.swift
//  NetworkKit
//
//  Created by Jack Pooley on 25/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

/// A networking error returned by the network layer, this can be mapped to user facing errors at a high level
public enum NetworkCommunicatorError: Error {
    case urlError(URLError)
    case serverError(HTTPRequestServerError)
    case rawServerError(ServerErrorResponseNew)
    case payloadError(HTTPRequestPayloadError)
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

/// Errors returned when there is an unexpected response
public enum HTTPRequestServerError: Error {
    case badResponse
}

/// Errors to represent invalid or empty payload errors
public enum HTTPRequestPayloadError: Error {
    case emptyData
    case badData(rawPayload: String)
}
