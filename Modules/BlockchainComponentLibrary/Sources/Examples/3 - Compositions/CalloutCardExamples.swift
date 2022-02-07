// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct CalloutCardExamples: View {

    var body: some View {
        VStack(spacing: Spacing.baseline) {
            CalloutCard(
                leading: {
                    Icon.moneyUSD
                },
                title: "Buy More Crypto",
                message: "Upgrade Your Wallet",
                control: .init(
                    title: "GO",
                    action: {}
                )
            )
        }
        .padding()
    }
}
