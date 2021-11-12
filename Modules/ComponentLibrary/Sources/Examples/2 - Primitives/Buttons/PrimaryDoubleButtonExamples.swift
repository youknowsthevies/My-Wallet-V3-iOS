// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct PrimaryDoubleButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            PrimaryDoubleButton(
                leadingTitle: "leading enabled",
                leadingAction: {},
                trailingTitle: "trailing enabled",
                trailingAction: {}
            )

            PrimaryDoubleButton(
                leadingTitle: "leading rtl",
                leadingAction: {},
                trailingTitle: "trailing rtl",
                trailingAction: {}
            )
            .environment(\.layoutDirection, .rightToLeft)

            PrimaryDoubleButton(
                leadingTitle: "leading disabled",
                leadingAction: {},
                trailingTitle: "trailing disabled",
                trailingAction: {}
            )
            .disabled(true)

            PrimaryDoubleButton(
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

struct PrimaryDoubleButtonExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryDoubleButtonExamplesView()
    }
}
