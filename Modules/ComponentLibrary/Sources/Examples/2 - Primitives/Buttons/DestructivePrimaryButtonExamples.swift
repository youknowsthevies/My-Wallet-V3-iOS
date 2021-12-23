// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct DestructivePrimaryButtonExamples: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            DestructivePrimaryButton(title: "Enabled", action: {})

            DestructivePrimaryButton(title: "Disabled", action: {})
                .disabled(true)

            DestructivePrimaryButton(title: "Loading", isLoading: true, action: {})
        }
        .padding(Spacing.padding())
    }
}

struct DestructivePrimaryButtonExamples_Previews: PreviewProvider {
    static var previews: some View {
        DestructivePrimaryButtonExamples()
    }
}
