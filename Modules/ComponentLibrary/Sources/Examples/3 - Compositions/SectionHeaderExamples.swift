// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct SectionHeaderExamplesView: View {

    private let data: NavigationLinkProviderList = [
        "Section Headers": [
            NavigationLinkProvider(view: WalletSectionHeaderExamplesView(), title: "WalletSectionHeader")
        ]
    ]

    var body: some View {
        NavigationLinkProviderView(data: data)
    }
}

struct SectionHeaderExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            SectionHeaderExamplesView()
        }
    }
}
