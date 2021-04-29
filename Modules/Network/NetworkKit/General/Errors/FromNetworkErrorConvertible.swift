// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Higher level `Error` types should conform to this to enable mapping from `NetworkError` errors
public protocol FromNetworkErrorConvertible: Error, Decodable {
    
    static func from(_ networkError: NetworkError) -> Self
}
