// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct LegalView: View {

    private let localizedStrings = LocalizationConstants.CardIssuing.Order.Details.self

    var body: some View {
        VStack(spacing: 0) {
            TitleRow(localizedStrings.Legal.consumerFinancialProtectionBureau)
            PrimaryDivider()
            Row(localizedStrings.Legal.shortFormDisclosure)
            PrimaryDivider()
            TitleRow(localizedStrings.Legal.blockchainTermsAndConditions)
            PrimaryDivider()
            Row(localizedStrings.Legal.termsAndConditions)
            Spacer()
        }
        .listStyle(PlainListStyle())
        .background(Color.semantic.background.ignoresSafeArea())
        .navigationTitle(localizedStrings.Legal.navigationTitle)
    }

    struct Row: View {
        let title: String
        let action: (() -> Void)?

        init(
            _ title: String,
            action: (() -> Void)? = nil
        ) {
            self.title = title
            self.action = action
        }

        var body: some View {
            if let action = action {
                Button(action: action) {
                    content
                }
            } else {
                content
            }
        }

        @ViewBuilder var content: some View {
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .typography(.paragraph2)
                    .foregroundColor(.WalletSemantic.title)
                Spacer()
                Icon.chevronRight
                    .frame(width: 18, height: 18)
                    .accentColor(
                        .WalletSemantic.overlay
                    )
                    .flipsForRightToLeftLayoutDirection(true)
            }
            .padding(.vertical, Spacing.padding2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.padding3)
        }
    }

    struct TitleRow: View {
        let title: String

        init(_ title: String) {
            self.title = title
        }

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .typography(.paragraph2)
                    .foregroundColor(.WalletSemantic.overlay)
                    .padding(.leading, Spacing.padding2)
                Spacer()
            }
            .padding(.vertical, Spacing.padding2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.padding3)
        }
    }
}

#if DEBUG
struct Legal_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LegalView()
        }
    }
}
#endif
