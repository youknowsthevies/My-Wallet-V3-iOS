// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum NabuErrorType: String, Codable, Equatable {

    // Unknown
    case unknown

    // Generic HTTP errors
    case internalServerError = "INTERNAL_SERVER_ERROR"
    case notFound = "NOT_FOUND"
    case badMethod = "BAD_METHOD"
    case conflict = "CONFLICT"

    // Generic user input errors
    case missingBody = "MISSING_BODY"
    case missinParam = "MISSING_PARAM"
    case badParamValue = "BAD_PARAM_VALUE"

    // Authentication errors
    case forbidden = "FORBIDDEN"
    case invalidCredentials = "INVALID_CREDENTIALS"
    case wrongPassword = "WRONG_PASSWORD"
    case wrong2FA = "WRONG_2FA"
    case bad2FA = "BAD_2FA"
    case unknownUser = "UNKNOWN_USER"
    case invalidRole = "INVALID_ROLE"
    case alreadyLoggedIn = "ALREADY_LOGGED_IN"
    case invalidStatus = "INVALID_STATUS"
}
