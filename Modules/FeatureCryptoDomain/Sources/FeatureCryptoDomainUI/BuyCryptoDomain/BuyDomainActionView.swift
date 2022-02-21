// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCryptoDomainDomain
import Localization
import SwiftUI

struct BuyDomainActionView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.BuyDomain
    private typealias Accessibilty = AccessibilityIdentifiers.BuyDomainBottomSheet

    @Binding var domain: SearchDomainResult?
    @Binding var isShown: Bool

    var body: some View {
        VStack(alignment: .center, spacing: Spacing.padding2) {
            Text(String(format: LocalizedString.header, domain?.domainName ?? ""))
                .typography(.title3)
                .fixedSize(horizontal: false, vertical: true)
                .accessibility(identifier: Accessibilty.buyTitle)
            Text(LocalizedString.prompt)
                .typography(.paragraph1)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.semantic.overlay)
                .accessibility(identifier: Accessibilty.buyDescription)
            Spacer()
            PrimaryButton(
                title: LocalizedString.Button.buyDomain,
                leadingView: {
                    Icon.newWindow
                        .frame(width: 24, height: 24)
                },
                action: {
                    if case .premium(let url) = domain?.domainType {
                        UIApplication.shared.open(url) { _ in
                            isShown.toggle()
                        }
                    }
                }
            )
            .accessibility(identifier: Accessibilty.buyButton)
            MinimalButton(title: LocalizedString.Button.noThanks) {
                isShown.toggle()
            }
            .padding(.bottom, Spacing.padding3)
            .accessibility(identifier: Accessibilty.goBackButton)
        }
        .multilineTextAlignment(.center)
        .padding(Spacing.padding3)
    }
}

struct BuyDomainActionView_Previews: PreviewProvider {
    static var previews: some View {
        BuyDomainActionView(
            domain: .constant(
                SearchDomainResult(
                    domainName: "example.blockchain",
                    domainType: .free,
                    domainAvailability: .availableForFree
                )
            ),
            isShown: .constant(true)
        )
    }
}
