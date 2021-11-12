// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct MinimalDoubleButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            MinimalDoubleButton(
                leadingTitle: "leading enabled",
                leadingAction: {},
                trailingTitle: "trailing enabled",
                trailingAction: {}
            )

            MinimalDoubleButton(
                leadingTitle: "leading rtl",
                leadingAction: {},
                trailingTitle: "trailing rtl",
                trailingAction: {}
            )
            .environment(\.layoutDirection, .rightToLeft)

            MinimalDoubleButton(
                leadingTitle: "leading disabled",
                leadingAction: {},
                trailingTitle: "trailing disabled",
                trailingAction: {}
            )
            .disabled(true)

            MinimalDoubleButton(
                leadingTitle: "loading",
                leadingIsLoading: true,
                leadingAction: {},
                trailingTitle: "loading",
                trailingIsLoading: true,
                trailingAction: {}
            )
        }
        .padding(Spacing.padding())
    }
}

struct MinimalDoubleButtonExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        MinimalDoubleButtonExamplesView()
    }
}
