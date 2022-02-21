// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCryptoDomainDomain
import Localization
import SwiftUI

struct DomainCheckoutConfirmationView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.CheckoutConfirmation

    var domain: SearchDomainResult

    var body: some View {
        VStack(spacing: Spacing.padding3) {
            Spacer()
            Icon.globe
                .frame(width: 54, height: 54)
                .accentColor(.semantic.primary)
            Text(String(format: LocalizedString.title, domain.domainName))
                .typography(.title3)
            Text(LocalizedString.description)
                .typography(.paragraph1)
                .foregroundColor(.semantic.overlay)
            SmallMinimalButton(title: LocalizedString.learnMore) {
                // TODO: open learn more link
            }
            Spacer()
            PrimaryButton(title: LocalizedString.okayButton) {
                // TODO: okay action
            }
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
