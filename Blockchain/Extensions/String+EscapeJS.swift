// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

@objc extension NSString {
    func escapedForJS() -> String {
        (self as String).escapedForJS()
    }
}
