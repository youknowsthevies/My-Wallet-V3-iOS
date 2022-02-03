// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct SmallBuyButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            SmallBuyButton(title: "Enabled", action: {})

            SmallBuyButton(title: "Disabled", action: {})
                .disabled(true)

            SmallBuyButton(title: "Loading", isLoading: true, action: {})
        }
        .padding(Spacing.padding())
    }
}

struct SmallBuyButtonExamplesView_Previews: PreviewProvider {

    static var previews: some View {
        SmallBuyButtonExamplesView()
    }
}
