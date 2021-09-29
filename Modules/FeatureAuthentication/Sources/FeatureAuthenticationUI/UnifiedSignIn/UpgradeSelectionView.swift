// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

struct UpgradeSelectionView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.UpgradeAccount

    private enum Layout {
        static let topPadding: CGFloat = 50
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24
        static let bottomPadding: CGFloat = 34

        static let headingBottomPadding: CGFloat = 8
        static let subheadingFontSize: CGFloat = 16
        static let subheadingLineSpacing: CGFloat = 5

        static let buttonSpacing: CGFloat = 10
    }

    var body: some View {
        VStack {
            VStack {
                Text(LocalizedString.heading)
                    .textStyle(.title)
                    .padding(.bottom, Layout.headingBottomPadding)
                Text(LocalizedString.subheading)
                    .lineSpacing(Layout.subheadingLineSpacing)
                    .font(Font(weight: .medium, size: Layout.subheadingFontSize))
            }
            .multilineTextAlignment(.center)

            Spacer()
            MessageList(messages: createMessages())
            Spacer()

            VStack {
                PrimaryButton(
                    title: LocalizedString.upgradeAccountButton,
                    action: {
                        // TODO: add action
                    }
                )
                .accessibilityIdentifier(AccessibilityIdentifiers.UpgradeAccountScreen.upgradeButton)

                SecondaryButton(
                    title: LocalizedString.skipButton,
                    action: {
                        // TODO: add action
                    }
                )
                .accessibilityIdentifier(AccessibilityIdentifiers.UpgradeAccountScreen.skipButton)
            }
        }
        .padding(
            EdgeInsets(
                top: Layout.topPadding,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
        .navigationTitle(LocalizedString.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .hideBackButtonTitle()
    }

    private struct Message: Identifiable {
        let id: Int
        let iconName: String
        let title: String
        let detailedMessage: String
    }

    private struct MessageList: View {

        let messages: [Message]

        var body: some View {
            VStack(alignment: .leading) {
                ForEach(messages) {
                    MessageRow(message: $0)
                        .padding(.top, 5)
                        .padding(.bottom, 25)
                }
            }
        }
    }

    private struct MessageRow: View {

        let message: Message

        var body: some View {
            HStack(alignment: .top) {
                Image(message.iconName)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 5)
                VStack(alignment: .leading) {
                    Text(message.title)
                        .textStyle(.heading)
                    Text(message.detailedMessage)
                        .textStyle(.body)
                }
            }
        }
    }

    private func createMessages() -> [Message] {
        [
            Message(
                id: 1,
                iconName: "number-one",
                title: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.headingOne,
                detailedMessage: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.bodyOne
            ),
            Message(
                id: 2,
                iconName: "number-two",
                title: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.headingTwo,
                detailedMessage: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.bodyTwo
            ),
            Message(
                id: 3,
                iconName: "number-three",
                title: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.headingThree,
                detailedMessage: LocalizationConstants.FeatureAuthentication.UpgradeAccount.MessageList.bodyThree
            )
        ]
    }
}
