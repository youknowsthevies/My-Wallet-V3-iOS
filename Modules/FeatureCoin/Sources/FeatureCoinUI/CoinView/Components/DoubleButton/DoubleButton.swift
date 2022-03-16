// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

struct DoubleButton: View {

    var primaryAction: DoubleButtonAction?
    var secondaryAction: DoubleButtonAction?

    let action: (DoubleButtonAction) -> Void

    init(
        primaryAction: DoubleButtonAction?,
        secondaryAction: DoubleButtonAction?,
        action: @escaping (DoubleButtonAction) -> Void
    ) {
        self.action = action
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    var body: some View {
        VStack {
            HStack {
                if let secondaryAction = secondaryAction {
                    SecondaryButton(
                        title: secondaryAction.title,
                        leadingView: {
                            secondaryAction.icon
                        },
                        action: {
                            action(secondaryAction)
                        }
                    )
                }
                if let primaryAction = primaryAction {
                    PrimaryButton(
                        title: primaryAction.title,
                        leadingView: {
                            primaryAction.icon
                        },
                        action: {
                            action(primaryAction)
                        }
                    )
                }
            }
            .padding()
        }
    }

    // swiftlint:disable type_name
    struct MainCtaView_PreviewProvider: PreviewProvider {
        static var previews: some View {
            Group {
                DoubleButton(
                    primaryAction: .buy,
                    secondaryAction: .sell,
                    action: { _ in }
                )
                DoubleButton(
                    primaryAction: .send,
                    secondaryAction: .receive,
                    action: { _ in }
                )
            }
        }
    }
}
