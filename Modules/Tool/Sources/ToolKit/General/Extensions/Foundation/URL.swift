// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension URL: ExpressibleByStringLiteral {

    public init(stringLiteral value: StaticString) {
        self.init(
            string: value.hasPointerRepresentation
                ? value.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
                : .init(value.unicodeScalar)
        )!
    }
}
