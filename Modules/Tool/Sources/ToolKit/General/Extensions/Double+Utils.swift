// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Double {

    /// Returns a string representation of the current value.
    ///
    /// - Parameter decimalPrecision: A number of decimal places.
    public func string(with decimalPrecision: Int) -> String {
        String(format: "%.\(decimalPrecision)f", self)
    }
}
