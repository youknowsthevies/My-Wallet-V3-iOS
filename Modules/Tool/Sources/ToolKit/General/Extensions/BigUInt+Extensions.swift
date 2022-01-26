// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

extension BigUInt {
    public static let zero = BigUInt(0)
}

extension BigUInt {
    /// Even-length hexadecimal string representation of this element.
    public var hexString: String {
        let string = String(self, radix: 16)
        // Check odd length hex string
        if string.count % 2 != 0 {
            return "0" + string
        }
        return string
    }
}

extension BigUInt {
    public var decimal: Decimal {
        Decimal(string: String(self))!
    }
}
