// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum AuthorizationResult {
    case success
    case requestDenied
    case linkExpired
    // other network errors
    case unknown
}
