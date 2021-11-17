// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

// swiftlint:disable line_length
struct ActionRowExamplesView: View {

    var body: some View {
        List {
            ActionRow(
                title: "Back Up Your Wallet",
                subtitle: "Step 1"
            ) {
                Icon.wallet
                    .fixedSize()
                    .accentColor(Color.semantic.dark)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            ActionRow(
                title: "Gold Level",
                subtitle: "Higher Trading Limits",
                tags: [Tag(text: "Approved", variant: .success)]
            ) {
                Icon.apple
                    .fixedSize()
                    .accentColor(.semantic.orangeBG)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            ActionRow(
                title: "Trade",
                subtitle: "BTC -> ETH"
            ) {
                Icon.trade
                    .fixedSize()
                    .accentColor(.semantic.success)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            ActionRow(
                title: "Link a Bank",
                subtitle: "Instant Connection",
                description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                tags: [
                    Tag(text: "Fastest", variant: .success),
                    Tag(text: "Warning Alert", variant: .warning)
                ]
            ) {
                Icon.bank
                    .fixedSize()
                    .accentColor(.semantic.primary)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            ActionRow(title: "Features and Limits") {
                Icon.blockchain
                    .fixedSize()
                    .accentColor(.semantic.primary)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
        }
        .padding(.vertical, Spacing.padding3)
    }
}

struct ActionRowExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        ActionRowExamplesView()
    }
}
