// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct BottomSheetExamples: View {

    @State var isPresented: Bool = true

    var body: some View {
        Color.gray
            .onTapGesture {
                isPresented.toggle()
            }
            .overlay(
                BottomSheetView(
                    isPresented: $isPresented,
                    maximumHeight: 70.vh
                ) {
                    Group {
                        PrimaryRow(
                            title: "Swap",
                            subtitle: "Exchange for Another Crypto"
                        )

                        PrimaryDivider()
                    }

                    Group {
                        PrimaryRow(
                            title: "Send",
                            subtitle: "Send to Any Wallet"
                        )

                        PrimaryDivider()
                    }

                    Group {
                        PrimaryRow(
                            title: "Receive",
                            subtitle: "Copy Your Address & QR Codes"
                        )

                        PrimaryDivider()
                    }

                    Group {
                        PrimaryRow(
                            title: "Rewards",
                            subtitle: "Earn Rewards on Your Crypto"
                        )

                        PrimaryDivider()
                    }

                    Group {
                        PrimaryRow(
                            title: "Add Cash",
                            subtitle: "Add Cash from Your Bank"
                        )

                        PrimaryDivider()
                    }

                    PrimaryRow(
                        title: "Cash Out",
                        subtitle: "Withdraw Cash to Your Bank"
                    )

                    HStack {
                        PrimaryButton(title: "Buy", action: {})

                        SecondaryButton(title: "Sell", action: {})
                    }
                    .padding(Spacing.padding())
                }
            )
            .ignoresSafeArea()
    }
}

struct BottomSheetExamples_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetExamples()
    }
}
