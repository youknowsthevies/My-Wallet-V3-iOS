// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct SmallPrimaryButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.baseline) {
            SmallPrimaryButton(title: "OK", isLoading: false) {
                print("Tapped")
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled")

            SmallPrimaryButton(title: "OK", isLoading: false) {
                print("Tapped")
            }
            .disabled(true)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Disabled")

            SmallPrimaryButton(title: "OK", isLoading: true) {
                print("Tapped")
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Loading")
        }
        .padding()
    }
}

struct SmallPrimaryButtonExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        SmallPrimaryButtonExamplesView()
    }
}
