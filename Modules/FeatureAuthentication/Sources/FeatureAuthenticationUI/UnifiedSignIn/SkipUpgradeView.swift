// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

struct SkipUpgradeView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.SkipUpgrade

    private enum Layout {
        static let bottomPadding: CGFloat = 34
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24

        static let imageSideLength: CGFloat = 72
        static let imageBottomPadding: CGFloat = 16
        static let descriptionFontSize: CGFloat = 16
        static let descriptionLineSpacing: CGFloat = 4
        static let buttonSpacing: CGFloat = 10
    }

    var body: some View {
        VStack {
            VStack {
                Spacer()
                Image.CircleIcon.warning
                    .frame(width: Layout.imageSideLength, height: Layout.imageSideLength)
                    .padding(.bottom, Layout.imageBottomPadding)
                    .accessibility(identifier: AccessibilityIdentifiers.SkipUpgradeScreen.skipUpgradeImage)

                Text(LocalizedString.title)
                    .textStyle(.title)
                    .accessibility(identifier: AccessibilityIdentifiers.SkipUpgradeScreen.skipUpgradeTitleText)

                Text(LocalizedString.message)
                    .font(Font(weight: .medium, size: Layout.descriptionFontSize))
                    .foregroundColor(.textSubheading)
                    .lineSpacing(Layout.descriptionLineSpacing)
                    .accessibility(identifier: AccessibilityIdentifiers.SkipUpgradeScreen.skipUpgradeMessageText)
                Spacer()
            }
            .multilineTextAlignment(.center)
            VStack(spacing: Layout.buttonSpacing) {
                PrimaryButton(
                    title: LocalizedString.Button.skipUpgrade,
                    action: {
                        // TODO: add action here
                    }
                )
                .accessibility(identifier: AccessibilityIdentifiers.SkipUpgradeScreen.skipUpgradeButton)

                SecondaryButton(
                    title: LocalizedString.Button.upgradeAccount,
                    action: {
                        // TODO: add action here
                    }
                )
                .accessibility(identifier: AccessibilityIdentifiers.SkipUpgradeScreen.upgradeAccountButton)
            }
        }
        .padding(
            EdgeInsets(
                top: 0,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .hideBackButtonTitle()
    }
}

#if DEBUG
struct SkipUpgradeView_Previews: PreviewProvider {
    static var previews: some View {
        SkipUpgradeView()
    }
}
#endif
