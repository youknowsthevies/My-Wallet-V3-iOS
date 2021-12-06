// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension Color {

    public static func trend(for percentage: Decimal) -> Color {
        let color: Color
        if percentage > .zero {
            color = .positiveTrend
        } else if percentage < .zero {
            color = .negativeTrend
        } else {
            color = .neutralTrend
        }
        return color
    }
}

extension View {

    public func foregroundColorBasedOnPercentageChange(_ percentage: Decimal) -> some View {
        foregroundColor(.trend(for: percentage))
    }
}

extension Text {

    public func foregroundColorBasedOnPercentageChange(_ percentage: Decimal) -> Text {
        foregroundColor(.trend(for: percentage))
    }
}
