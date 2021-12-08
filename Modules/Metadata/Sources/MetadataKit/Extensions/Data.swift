// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Data {

    static func from(utf8string: String) -> Self {
        Self(utf8string.utf8)
    }
}

// MARK: SHA256 of SHA256

extension Data {
    var doubleSHA256: Data {
        sha256().sha256()
    }
}
