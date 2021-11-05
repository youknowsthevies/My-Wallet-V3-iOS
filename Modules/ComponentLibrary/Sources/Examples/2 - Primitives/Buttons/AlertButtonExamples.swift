// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct AlertButtonExamplesView: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            AlertButton(title: "Enabled", action: { print("foo") })

            AlertButton(title: "Loading", isLoading: true, action: {})
        }
        .padding(Spacing.padding())
    }
}

struct AlertButtonExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        AlertButtonExamplesView()
    }
}
