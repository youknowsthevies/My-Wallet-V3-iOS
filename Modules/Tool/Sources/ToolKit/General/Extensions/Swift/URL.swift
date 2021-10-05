// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension URL: ExpressibleByStringLiteral {

    public init(stringLiteral value: StaticString) {
        self.init(string: value.description)!
    }
}
