// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct ChartBalanceExamples: View {
    var body: some View {
        VStack {
            ChartBalance(
                title: "Current Balance",
                balance: "$2,574.37",
                changeArrow: "↑",
                changeAmount: "$95.23",
                changePercentage: "(34.53%)",
                changeColor: .semantic.success,
                changeTime: "Past Hour"
            )

            ChartBalance(
                title: "Current Balance",
                balance: "$2,574.37",
                changeArrow: "↓",
                changeAmount: "$95.23",
                changePercentage: "(34.53%)",
                changeColor: .semantic.error,
                changeTime: "Past Hour"
            )

            ChartBalance(
                title: "Current Balance",
                balance: "$2,574.37",
                changeArrow: "->",
                changeAmount: "$0.00",
                changePercentage: "(0.00%)",
                changeColor: .semantic.primary,
                changeTime: "Past Hour"
            )

            ChartBalance(
                title: "Current Balance",
                balance: "$2,574.37",
                changeArrow: "↑",
                changeAmount: "$95.23",
                changePercentage: "(34.53%)",
                changeColor: .semantic.success,
                changeTime: nil
            )
        }
    }
}

struct ChartBalanceExamples_Previews: PreviewProvider {
    static var previews: some View {
        ChartBalanceExamples()
    }
}
