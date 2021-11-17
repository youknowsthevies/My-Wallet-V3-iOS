// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

// swiftlint:disable line_length
struct DefaultRowExamplesView: View {

    var body: some View {
        List {
            DefaultRow(
                title: "Trading",
                subtitle: "Buy & Sell"
            )
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            DefaultRow(
                title: "Email Address",
                subtitle: "satoshi@blockchain.com",
                tags: [Tag(text: "Confirmed", variant: .success)]
            )
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            DefaultRow(
                title: "From: BTC Trading Account",
                subtitle: "To: 0x093871209487120934812"
            )
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            DefaultRow(
                title: "Link a Bank",
                subtitle: "Instant Connection",
                description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                tags: [
                    Tag(text: "Fastest", variant: .success),
                    Tag(text: "Warning Alert", variant: .warning)
                ]
            )
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            DefaultRow(
                title: "Cloud Backup",
                subtitle: "Buy & Sell"
            ) {
                Switch()
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            DefaultRow(
                title: "Features and Limits"
            )
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
        }
        .padding(.vertical, Spacing.padding3)
    }

    private struct Switch: View {
        @State var isOn: Bool = false

        var body: some View {
            PrimarySwitch(
                variant: .green,
                accessibilityLabel: "Test",
                isOn: $isOn
            )
        }
    }
}

struct DefaultRowExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultRowExamplesView()
    }
}
