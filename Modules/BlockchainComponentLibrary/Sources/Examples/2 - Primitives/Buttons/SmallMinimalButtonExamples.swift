// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct SmallMinimalButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.baseline) {
            SmallMinimalButton(title: "OK", isLoading: false) {
                print("Tapped")
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Enabled")

            SmallMinimalButton(title: "OK", isLoading: false) {
                print("Tapped")
            }
            .disabled(true)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Disabled")

            SmallMinimalButton(title: "OK", isLoading: true) {
                print("Tapped")
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Loading")
        }
        .padding()
    }
}

struct SmallMinimalButtonExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        SmallMinimalButtonExamplesView()
    }
}
