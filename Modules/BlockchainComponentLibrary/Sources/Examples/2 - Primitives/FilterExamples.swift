// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct FilterExamples: View {
    @State var firstSelection: AnyHashable = "leading"
    @State var secondSelection: AnyHashable = "trailing"
    @State var thirdSelection: AnyHashable = "USD"
    @State var forthSelection: AnyHashable = "EUR"

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            Filter(
                items: [
                    Filter.Item(title: "Leading", identifier: "leading"),
                    Filter.Item(title: "Trailing", identifier: "trailing")
                ],
                selection: $firstSelection
            )

            Filter(
                items: [
                    Filter.Item(title: "Leading", identifier: "leading"),
                    Filter.Item(title: "Trailing", identifier: "trailing")
                ],
                selection: $secondSelection
            )

            Filter(
                items: [
                    Filter.Item(title: "USD", identifier: "USD"),
                    Filter.Item(title: "GBP", identifier: "GBP"),
                    Filter.Item(title: "EUR", identifier: "EUR")
                ],
                selection: $thirdSelection
            )

            Filter(
                items: [
                    Filter.Item(title: "USD", identifier: "USD"),
                    Filter.Item(title: "GBP", identifier: "GBP"),
                    Filter.Item(title: "EUR", identifier: "EUR"),
                    Filter.Item(title: "USD", identifier: "CLP"),
                    Filter.Item(title: "GBP", identifier: "CZK")
                ],
                selection: $forthSelection
            )
        }
        .padding(Spacing.padding())
    }
}

struct FilterExamples_Previews: PreviewProvider {
    static var previews: some View {
        FilterExamples()
    }
}
