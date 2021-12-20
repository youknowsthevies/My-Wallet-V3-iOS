// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Data {
    /// Converts the data to a hex string
    public var toHexString: String {
        lazy
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}
