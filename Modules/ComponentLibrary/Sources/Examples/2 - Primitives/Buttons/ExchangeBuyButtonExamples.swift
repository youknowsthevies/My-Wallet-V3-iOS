// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct ExchangeBuyButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            ExchangeBuyButton(title: "Enabled", action: {})

            ExchangeBuyButton(title: "Disabled", action: {})
                .disabled(true)

            ExchangeBuyButton(title: "Loading", isLoading: true, action: {})
        }
        .padding(Spacing.padding())
    }
}

struct ExchangeBuyButtonExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeBuyButtonExamplesView()
    }
}
