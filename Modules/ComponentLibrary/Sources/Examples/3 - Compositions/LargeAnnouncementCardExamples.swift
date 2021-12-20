// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct LargeAnnouncementCardExamples: View {
    var body: some View {
        VStack(spacing: 16) {
            LargeAnnouncementCard(
                title: "Uniswap (UNI) is Now Trading",
                message: "Exchange, deposit, withdraw, or store UNI in your Blockchain.com Exchange account.",
                control: Control(title: "Trade UNI", action: {}),
                mainColor: .semantic.success,
                primaryTopText: "1 UNI = $21.19",
                secondaryTopText: "+$1.31 (5.22%)",
                tertiaryTopText: "Today",
                onCloseTapped: {},
                leading: { Icon.trade }
            )

            LargeAnnouncementCard(
                title: "Title",
                message: "Message",
                control: Control(title: "Control Title", action: {}),
                mainColor: .semantic.error,
                primaryTopText: "PrimaryTopText",
                secondaryTopText: "SecondaryTopText",
                tertiaryTopText: "TertiaryTopText",
                onCloseTapped: {},
                leading: { Icon.trade }
            )
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
}

struct LargeAnnouncementCardExamples_Previews: PreviewProvider {
    static var previews: some View {
        LargeAnnouncementCardExamples()
    }
}
