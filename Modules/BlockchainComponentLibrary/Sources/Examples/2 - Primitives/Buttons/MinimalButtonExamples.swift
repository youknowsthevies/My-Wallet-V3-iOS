// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct MinimalButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            MinimalButton(title: "Enabled", action: {})

            MinimalButton(title: "With Icon", leadingView: { Icon.placeholder }, action: {})

            MinimalButton(title: "Disabled", action: {})
                .disabled(true)

            MinimalButton(title: "Loading", isLoading: true, action: {})

            MinimalButton(title: "Custom Text Color", foregroundColor: .semantic.error, action: {})
        }
        .padding(Spacing.padding())
    }
}

struct MinimalButtonExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        MinimalButtonExamplesView()
    }
}
