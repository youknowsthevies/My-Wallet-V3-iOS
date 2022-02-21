// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCryptoDomainDomain
import Localization
import SwiftUI

struct DomainCheckoutConfirmationView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.CheckoutConfirmation
    private typealias Accessibility = AccessibilityIdentifiers.CheckoutConfirmation

    var domain: SearchDomainResult

    var body: some View {
        VStack(spacing: Spacing.padding3) {
            Spacer()
            Icon.globe
                .frame(width: 54, height: 54)
                .accentColor(.semantic.primary)
                .accessibility(identifier: Accessibility.icon)
            Text(String(format: LocalizedString.title, domain.domainName))
                .typography(.title3)
                .accessibility(identifier: Accessibility.title)
            Text(LocalizedString.description)
                .typography(.paragraph1)
                .foregroundColor(.semantic.overlay)
                .accessibility(identifier: Accessibility.description)
            SmallMinimalButton(title: LocalizedString.learnMore) {
                // TODO: open learn more link
            }
            .accessibility(identifier: Accessibility.learnMoreButton)
            Spacer()
            PrimaryButton(title: LocalizedString.okayButton) {
                // TODO: okay action
            }
            .accessibility(identifier: Accessibility.okayButton)
        }
        .navigationBarBackButtonHidden(true)
        .multilineTextAlignment(.center)
        .padding([.leading, .trailing], Spacing.padding3)
    }
}

struct DomainCheckoutConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        DomainCheckoutConfirmationView(
            domain: SearchDomainResult(
                domainName: "example.blockchain",
                domainType: .free,
                domainAvailability: .availableForFree
            )
        )
    }
}
