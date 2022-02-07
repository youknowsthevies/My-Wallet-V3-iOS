// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct BuyButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            BuyButton(title: "Enabled", action: {})

            BuyButton(title: "Disabled", action: {})
                .disabled(true)

            BuyButton(title: "Loading", isLoading: true, action: {})
        }
        .padding(Spacing.padding())
    }
}

struct BuyButtonExamplesView_Previews: PreviewProvider {

    static var previews: some View {
        BuyButtonExamplesView()
    }
}
