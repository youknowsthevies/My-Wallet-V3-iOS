// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct SmallSecondaryButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.baseline) {
            SmallSecondaryButton(title: "OK", isLoading: false) {
                print("Tapped")
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled")

            SmallSecondaryButton(title: "OK", isLoading: false) {
                print("Tapped")
            }
            .disabled(true)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Disabled")

            SmallSecondaryButton(title: "OK", isLoading: true) {
                print("Tapped")
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Loading")
        }
        .padding()
    }
}

struct SmallSecondaryButtonExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        SmallSecondaryButtonExamplesView()
    }
}
