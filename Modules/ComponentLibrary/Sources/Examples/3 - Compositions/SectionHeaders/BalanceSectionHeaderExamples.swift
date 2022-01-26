// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct BalanceSectionHeaderExamples: View {
    var body: some View {
        VStack {
            BalanceSectionHeader(
                title: "$12,293.21",
                subtitle: "0.1393819 BTC"
            ) {
                IconButton(icon: .favorite) {}
            }
            .previewLayout(.sizeThatFits)
        }
    }
}

struct BalanceSectionHeaderExamples_Previews: PreviewProvider {
    static var previews: some View {
        BalanceSectionHeaderExamples()
    }
}
