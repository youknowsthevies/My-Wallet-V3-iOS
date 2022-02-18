// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import SwiftUI

struct BuyDomainActionView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.BuyDomain

    var body: some View {
        VStack(alignment: .center, spacing: Spacing.padding3) {
            Text(LocalizedString.header)
                .typography(.title3)
            Text(LocalizedString.prompt)
                .typography(.paragraph1)
                .foregroundColor(.semantic.overlay)
            Spacer()
            PrimaryButton(
                title: LocalizedString.Button.buyDomain,
                leadingView: {
                    Icon.newWindow
                        .frame(width: 24, height: 24)
                },
                action: {
                    // TODO: open new window
                }
            )
        }
    }
}

struct BuyDomainActionView_Previews: PreviewProvider {
    static var previews: some View {
        BuyDomainActionView()
    }
}
