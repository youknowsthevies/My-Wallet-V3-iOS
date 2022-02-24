// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct TagViewExamples: View {
    var body: some View {
        VStack(spacing: Spacing.baseline) {
            TagView(text: "default") // variant: .default
            TagView(text: "default", size: .large) // variant: .default

            TagView(text: "infoAlt", variant: .infoAlt)
            TagView(text: "infoAlt", variant: .infoAlt, size: .large)

            TagView(text: "success", variant: .success)
            TagView(text: "success", variant: .success, size: .large)

            TagView(text: "warning", variant: .warning)
            TagView(text: "warning", variant: .warning, size: .large)

            TagView(text: "error", variant: .error)
            TagView(text: "error", variant: .error, size: .large)
        }
        .padding(Spacing.padding())
    }
}

struct TagViewExamples_Previews: PreviewProvider {
    static var previews: some View {
        TagViewExamples()
    }
}
