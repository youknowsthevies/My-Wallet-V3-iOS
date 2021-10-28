// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SwiftUI

struct TabBarExamplesView: View {
    @State var wallet: AnyHashable = TabBar_Previews.WalletPreviewContainer.Tab.home
    @State var exchange: AnyHashable = TabBar_Previews.ExchangePreviewContainer.Tab.home

    var body: some View {
        NavigationLinkProviderView(
            data: [
                "Examples": [
                    NavigationLinkProvider(
                        view: TabBar_Previews.WalletPreviewContainer(
                            activeTabIdentifier: wallet,
                            fabIsActive: false
                        ),
                        title: "Wallet"
                    ),
                    NavigationLinkProvider(
                        view: TabBar_Previews.ExchangePreviewContainer(
                            activeTabIdentifier: exchange
                        ),
                        title: "Exchange"
                    )
                ]
            ]
        )
    }
}

struct TabBarExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarExamplesView()
    }
}
