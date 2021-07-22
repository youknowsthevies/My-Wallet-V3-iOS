// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import SettingsKit

extension String {

    /// Returns the first 5 characters of the SHA256 hash of this string
    var passwordPartHash: String? {
        let hashedString = sha256
        let endIndex = hashedString.index(hashedString.startIndex, offsetBy: min(count, 5))
        return String(hashedString[..<endIndex])
    }
}
