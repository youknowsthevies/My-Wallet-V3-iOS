// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCryptoDomainDomain
import Localization
import SwiftUI

struct BuyDomainActionView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.BuyDomain
    private typealias Accessibilty = AccessibilityIdentifiers.BuyDomainBottomSheet

    var domainName: String
    var redirectUrl: String
    @Binding var isShown: Bool
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(alignment: .center, spacing: Spacing.padding2) {
            Text(String(format: LocalizedString.header, domainName))
                .typography(.title3)
                .fixedSize(horizontal: false, vertical: true)
                .accessibility(identifier: Accessibilty.buyTitle)
            Text(LocalizedString.prompt)
                .typography(.paragraph1)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.semantic.overlay)
                .padding(.bottom, Spacing.padding3)
                .accessibility(identifier: Accessibilty.buyDescription)
            PrimaryButton(
                title: LocalizedString.Button.buyDomain,
                leadingView: {
                    Icon.newWindow
                        .frame(width: 24, height: 24)
                },
                action: {
                    if let url = URL(string: redirectUrl) {
                        openURL(url) { _ in
                            withAnimation(.linear(duration: 0.2)) {
                                isShown.toggle()
                            }
                        }
                    }
                }
            )
            .accessibility(identifier: Accessibilty.buyButton)
            MinimalButton(title: LocalizedString.Button.noThanks) {
                withAnimation(.linear(duration: 0.2)) {
                    isShown.toggle()
                }
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
            domainName: "example.blockchain",
            redirectUrl: "https://www.blockchain.com",
            isShown: .constant(true)
        )
    }
}
