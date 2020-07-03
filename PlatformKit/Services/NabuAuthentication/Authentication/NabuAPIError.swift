//
//  NabuAPIError.swift
//  PlatformKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit

enum NabuAPIError: Int, Error {
    
    /// 401
    case tokenExpired = 401
    
    /// 409
    case alreadyRegistered = 409
    
    init?(error: Error) {
        guard let networkCommunicatorError = error as? NetworkCommunicatorError else {
            return nil
        }
        
        switch networkCommunicatorError {
        case .serverError(let serverError):
            guard case .badStatusCode = serverError, let apiError = NabuAPIError(rawValue: serverError.code ?? 0) else {
                return nil
            }
            self = apiError
            return
        case .rawServerError(let serverError):
            guard let apiError = NabuAPIError(rawValue: serverError.response.statusCode) else {
                return nil
            }
            self = apiError
            return
        default:
            return nil
        }
    }
}

