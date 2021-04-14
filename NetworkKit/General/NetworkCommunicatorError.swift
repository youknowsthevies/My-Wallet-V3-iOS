//
//  NetworkCommunicatorError.swift
//  PlatformKit
//
//  Created by Jack on 06/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit

public enum NetworkCommunicatorError: Error {
    case unknown(Error)
    case clientError(HTTPRequestClientError)
    case rawServerError(ServerErrorResponse)
    case serverError(HTTPRequestServerError)
    case payloadError(HTTPRequestPayloadError)
    
    func analyticsEvent(for request: NetworkRequest, decodeErrorResponse: ((ServerErrorResponse) -> String?)? = nil) -> AnalyticsEvent? {
        switch self {
        case .unknown:
            return nil
        case .clientError(let clientError):
            return NetworkErrorEvent(request: request, error: clientError)
        case .rawServerError, .serverError, .payloadError:
            return APIErrorEvent(request: request, error: self, decodeErrorResponse: decodeErrorResponse)
        }
    }
}

enum NetworkErrorEvent: AnalyticsEvent {
    case unknown
    case clientError(ErrorDetails?)
    
    struct ErrorDetails {
        var params: [String: String] {
            var parameters: [String: String] = [
                "host": host,
                "path": path
            ]
            if let message = message {
                parameters["message"] = message
            }
            return parameters
        }
        
        let host: String
        let path: String
        let message: String?
        
        init?(request: NetworkRequest, message: String? = nil) {
            guard
                let url = request.URLRequest.url,
                let host = url.host
                else {
                    return nil
            }
            self.host = host
            self.path = url.path
            self.message = message
        }
    }
    
    init?(request: NetworkRequest, error: HTTPRequestClientError) {
        switch error {
        case .failedRequest(let description):
            self = .clientError(ErrorDetails(request: request, message: description))
        case .reachability:
            self = .clientError(ErrorDetails(request: request, message: error.debugDescription))
        }
    }
    
    init?(request: NetworkRequest, error: URLError) {
        self = .clientError(ErrorDetails(request: request, message: error.localizedDescription))
    }
    
    var name: String {
        "network_error"
    }
    
    var params: [String : String]? {
        switch self {
        case .unknown:
            return [:]
        case .clientError(let details):
            return details?.params ?? [:]
        }
    }
}

enum APIErrorEvent: AnalyticsEvent {
    case payloadError(ErrorDetails?)
    case serverError(ErrorDetails?)
    
    struct ErrorDetails {
        var params: [String: String] {
            var parameters: [String: String] = [
                "host": host,
                "path": path
            ]
            if let errorCode = errorCode {
                parameters["error_code"] = errorCode
            }
            if let body = body {
                parameters["body"] = body
            }
            if let requestId = requestId {
                parameters["request_id"] = requestId
            }
            return parameters
        }
        
        let host: String
        let path: String
        let errorCode: String?
        let body: String?
        let requestId: String?
        
        init?(request: NetworkRequest, errorResponse: ServerErrorResponse? = nil, body: String? = nil) {
            guard
                let url = request.URLRequest.url,
                let host = url.host
                else {
                    return nil
            }
            var errorCode: String?
            if let statusCode = errorResponse?.response.statusCode {
                errorCode = "\(statusCode)"
            }
            var requestId: String?
            if let headers = errorResponse?.response.allHeaderFields, let requestIdHeader = headers["X-WR-RequestId"] as? String {
                requestId = requestIdHeader
            }
            self.host = host
            self.path = url.path
            self.errorCode = errorCode
            self.body = body
            self.requestId = requestId
        }
        
        static func from(request: NetworkRequest, errorResponse: ServerErrorResponseNew? = nil, body: String? = nil) -> Self? {
            self.init(
                request: request,
                errorResponse: errorResponse?.legacyError,
                body: body
            )
        }
    }
    
    var name: String {
        "api_error"
    }
    
    var params: [String : String]? {
        switch self {
        case .payloadError(let details), .serverError(let details):
            return details?.params ?? [:]
        }
    }
    
    init?(request: NetworkRequest, error: NetworkCommunicatorError, decodeErrorResponse: ((ServerErrorResponse) -> String?)? = nil) {
        switch error {
        case .rawServerError(let rawServerError):
            self = .serverError(ErrorDetails(
                request: request,
                errorResponse: rawServerError,
                body: decodeErrorResponse?(rawServerError)
            ))
        case .serverError, .payloadError:
            self = .serverError(ErrorDetails(
                request: request
            ))
        case .clientError, .unknown:
            return nil
        }
    }
    
    init?(request: NetworkRequest,
          error: NetworkCommunicatorErrorNew,
          decodeErrorResponse: ((ServerErrorResponseNew) -> String?)? = nil) {
        switch error {
        case .rawServerError(let rawServerError):
            self = .serverError(ErrorDetails.from(
                request: request,
                errorResponse: rawServerError,
                body: decodeErrorResponse?(rawServerError)
            ))
        case .serverError, .payloadError, .authentication:
            self = .serverError(
                ErrorDetails.from(
                    request: request
                )
            )
        case .urlError:
            return nil
        }
    }
}
