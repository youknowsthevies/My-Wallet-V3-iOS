//
//  NetworkCommunicatorLegacyError.swift
//  PlatformKit
//
//  Created by Jack on 06/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

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
