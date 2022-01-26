// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct DestructiveMinimalButtonExamples: View {

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            DestructiveMinimalButton(title: "Enabled", action: {})

            DestructiveMinimalButton(title: "Disabled", action: {})
                .disabled(true)

            DestructiveMinimalButton(title: "Loading", isLoading: true, action: {})
        }
        .padding(Spacing.padding())
    }
}

struct DestructiveMinimalButtonExamples_Previews: PreviewProvider {
    static var previews: some View {
        DestructiveMinimalButtonExamples()
    }
}
