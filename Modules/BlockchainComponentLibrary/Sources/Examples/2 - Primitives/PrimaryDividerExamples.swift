// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct PrimaryDividerExamples: View {
    var body: some View {
        VStack {
            VStack {
                Text("PrimaryDivider")
                    .typography(.body1)

                PrimaryDivider()

                Text("Horizontal")
                    .typography(.body1)
            }
            .fixedSize()

            HStack {
                Text("PrimaryDivider")
                    .typography(.body1)

                PrimaryDivider()

                Text("Vertical")
                    .typography(.body1)
            }
            .fixedSize()
        }
    }
}

struct PrimaryDividerExamples_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryDividerExamples()
    }
}
