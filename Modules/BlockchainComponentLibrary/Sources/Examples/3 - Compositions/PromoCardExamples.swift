// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct PromoCardExamples: View {
    var body: some View {
        VStack(spacing: 16) {
            PromoCard(
                title: "Welcome to Blockchain!",
                message: "This is your Portfolio view. Once you own and hold crypto, the balances display here.",
                icon: Icon.blockchain
            ) {}

            PromoCard(
                title: "Notify Me",
                message: "Get a notification when Uniswap is available to trade on Blockchain.com.",
                icon: Icon.notificationOn,
                control: Control(title: "Notify Me", action: {})
            ) {}
        }
        .frame(maxHeight: .infinity)
        .background(Color.semantic.dark)
    }
}

struct PromoCardExamples_Previews: PreviewProvider {
    static var previews: some View {
        PromoCardExamples()
    }
}
