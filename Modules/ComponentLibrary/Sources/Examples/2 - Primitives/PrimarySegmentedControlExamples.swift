// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct PrimarySegmentedControlExamples: View {
    @State var firstSelection: AnyHashable = "live"
    @State var secondSelection: AnyHashable = "1m"
    @State var thirdSelection: AnyHashable = "first"
    @State var fourthSelection: AnyHashable = "ready"

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            PrimarySegmentedControl(
                items: [
                    PrimarySegmentedControl.Item(title: "Live", variant: .dot, identifier: "live"),
                    PrimarySegmentedControl.Item(title: "1D", identifier: "1d"),
                    PrimarySegmentedControl.Item(title: "1W", identifier: "1w"),
                    PrimarySegmentedControl.Item(title: "1M", identifier: "1m"),
                    PrimarySegmentedControl.Item(title: "1Y", identifier: "1y"),
                    PrimarySegmentedControl.Item(title: "All", identifier: "all")
                ],
                selection: $firstSelection
            )

            PrimarySegmentedControl(
                items: [
                    PrimarySegmentedControl.Item(title: "Live", variant: .dot, identifier: "live"),
                    PrimarySegmentedControl.Item(title: "1D", identifier: "1d"),
                    PrimarySegmentedControl.Item(title: "1W", identifier: "1w"),
                    PrimarySegmentedControl.Item(title: "1M", identifier: "1m"),
                    PrimarySegmentedControl.Item(title: "1Y", identifier: "1y"),
                    PrimarySegmentedControl.Item(title: "All", identifier: "all")
                ],
                selection: $secondSelection
            )

            PrimarySegmentedControl(
                items: [
                    PrimarySegmentedControl.Item(title: "First", identifier: "first"),
                    PrimarySegmentedControl.Item(title: "Second", identifier: "second"),
                    PrimarySegmentedControl.Item(title: "Third", identifier: "third")
                ],
                selection: $thirdSelection
            )

            PrimarySegmentedControl(
                items: [
                    PrimarySegmentedControl.Item(title: "Today", variant: .dot, identifier: "today"),
                    PrimarySegmentedControl.Item(title: "Tomorrow", identifier: "tomorrow"),
                    PrimarySegmentedControl.Item(title: "Now", identifier: "now"),
                    PrimarySegmentedControl.Item(title: "Ready", variant: .dot, identifier: "ready")
                ],
                selection: $fourthSelection
            )
        }
        .padding(Spacing.padding())
    }
}

struct PrimarySegmentedControlExamples_Previews: PreviewProvider {
    static var previews: some View {
        PrimarySegmentedControlExamples()
    }
}
