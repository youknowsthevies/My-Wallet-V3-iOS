// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension Color {

    public static func trend(for percentage: Double) -> Color {
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

    public func foregroundColorBasedOnPercentageChange(_ percentage: Double) -> some View {
        foregroundColor(.trend(for: percentage))
    }
}

extension Text {

    public func foregroundColorBasedOnPercentageChange(_ percentage: Double) -> Text {
        foregroundColor(.trend(for: percentage))
    }
}
