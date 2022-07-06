// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation

struct PrimaryWhiteButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            PrimaryWhiteButton(title: "Enabled", action: {})

            PrimaryWhiteButton(title: "Disabled", action: {})
                .disabled(true)

            PrimaryWhiteButton(title: "Loading", isLoading: true, action: {})
        }
        .padding(Spacing.padding())
    }
}

struct PrimaryWhiteButtonExamplesView_Previews: PreviewProvider {

    static var previews: some View {
        PrimaryWhiteButtonExamplesView()
    }
}
