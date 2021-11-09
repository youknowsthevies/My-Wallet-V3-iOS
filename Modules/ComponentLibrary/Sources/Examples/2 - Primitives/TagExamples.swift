// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct TagExamples: View {
    var body: some View {
        VStack(spacing: Spacing.baseline) {
            Tag(text: "default") // variant: .default

            Tag(text: "infoAlt", variant: .infoAlt)

            Tag(text: "success", variant: .success)

            Tag(text: "warning", variant: .warning)

            Tag(text: "error", variant: .error)
        }
        .padding(Spacing.padding())
    }
}

struct TagExamples_Previews: PreviewProvider {
    static var previews: some View {
        TagExamples()
    }
}
