// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SwiftUI

struct BorderRadiiExamplesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.padding2) {
                Spacing_Previews.radiusView(
                    for: Spacing.buttonBorderRadius,
                    title: "8pt (Buttons)"
                )
                Spacing_Previews.radiusView(
                    for: Spacing.containerBorderRadius,
                    title: "16pt (Containers)"
                )
                Spacing_Previews.radiusView(
                    for: Spacing.roundedBorderRadius(for: 188),
                    title: "100% (Alerts)"
                )
            }
            .padding(Spacing.padding())
        }
    }
}

struct BorderRadiiExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        BorderRadiiExamplesView()
    }
}
