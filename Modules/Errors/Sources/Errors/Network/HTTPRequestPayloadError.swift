// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Errors to represent invalid or empty payload errors
public enum HTTPRequestPayloadError: Error {
    case emptyData
    case badData(rawPayload: String)
}
