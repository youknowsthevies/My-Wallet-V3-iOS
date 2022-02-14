// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import BlockchainComponentLibrary
import SwiftUI

struct AlertCardExamples: View {

    private var message: String {
        "Card alert copy that directs the user to take an action or let’s them know what happened."
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                example(title: "Default", variant: .default)

                example(title: "Success", variant: .success)

                example(title: "Warning", variant: .warning)

                example(title: "Error", variant: .error)
            }
            .padding()
        }
    }

    @ViewBuilder private func example(title: String, variant: AlertCard.Variant) -> some View {
        VStack {
            AlertCard(
                title: title,
                message: message,
                variant: variant,
                onCloseTapped: {}
            )
            AlertCard(
                title: "\(title) Bordered",
                message: message,
                variant: variant,
                isBordered: true,
                onCloseTapped: {}
            )
        }
    }
}

struct AlertCardExamples_Previews: PreviewProvider {
    static var previews: some View {
        AlertCardExamples()
    }
}
