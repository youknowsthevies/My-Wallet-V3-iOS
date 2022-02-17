// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI

// MARK: - ComposableArchitecture

// MARK: - ClaimBenefitsView

struct ClaimBenefitsView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.ClaimBenefits

    var body: some View {
        VStack(alignment: .center, spacing: Spacing.padding3) {
            benefitsHeader
                .padding([.leading, .trailing], Spacing.padding3)
            benefitsList
            Spacer()
            PrimaryButton(title: LocalizedString.claimButton) {}
                .padding([.leading, .trailing], Spacing.padding3)
        }
        .primaryNavigation(trailing: { closeButton })
    }

    private var closeButton: some View {
        Button(action: {}) {
            Icon.closeCirclev2
                .frame(width: 24, height: 24)
                .accentColor(.semantic.muted)
        }
    }

    private var benefitsHeader: some View {
        VStack(alignment: .center, spacing: Spacing.padding2) {
            Text(LocalizedString.Header.title)
                .typography(.title3)
            Text(LocalizedString.Header.description)
                .typography(.paragraph1)
                .foregroundColor(.semantic.overlay)
                .multilineTextAlignment(.center)
        }
    }

    private var benefitsList: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 10) {
                PrimaryRow(
                    title: LocalizedString.BenefitsList.SimplifyTransaction.title,
                    subtitle: LocalizedString.BenefitsList.SimplifyTransaction.description,
                    leading: {
                        Icon.flashOn
                            .frame(width: 24, height: 24)
                            .accentColor(.semantic.primary)
                    },
                    trailing: { EmptyView() }
                )
                PrimaryRow(
                    title: LocalizedString.BenefitsList.MultiNetwork.title,
                    subtitle: LocalizedString.BenefitsList.MultiNetwork.description,
                    leading: {
                        Icon.sell
                            .frame(width: 24, height: 24)
                            .accentColor(.semantic.primary)
                    },
                    trailing: { EmptyView() }
                )
                PrimaryRow(
                    title: LocalizedString.BenefitsList.Ownership.title,
                    subtitle: LocalizedString.BenefitsList.Ownership.description,
                    leading: {
                        Icon.verified
                            .frame(width: 24, height: 24)
                            .accentColor(.semantic.primary)
                    },
                    trailing: { EmptyView() }
                )
                PrimaryRow(
                    title: LocalizedString.BenefitsList.MuchMore.title,
                    subtitle: LocalizedString.BenefitsList.MuchMore.description,
                    leading: {
                        Icon.listBullets
                            .frame(width: 24, height: 24)
                            .accentColor(.semantic.primary)
                    },
                    trailing: { EmptyView() }
                )
            }
        }
    }
}

struct ClaimBenefitsView_Previews: PreviewProvider {
    static var previews: some View {
        ClaimBenefitsView()
    }
}
