// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct ExchangeSellButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            ExchangeSellButton(title: "Enabled", action: {})

            ExchangeSellButton(title: "Disabled", action: {})
                .disabled(true)

            ExchangeSellButton(title: "Loading", isLoading: true, action: {})
        }
        .padding(Spacing.padding())
    }
}

struct ExchangeSellButtonExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeSellButtonExamplesView()
    }
}
