// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
@testable import FeatureCryptoDomainUI
import SwiftUI

struct ContentView: View {
    var body: some View {
        PrimaryNavigationView {
            PrimaryNavigationLink(
                destination: SearchCryptoDomainView(
                    store: .init(
                        initialState: .init(),
                        reducer: searchCryptoDomainReducer,
                        environment: .init(mainQueue: .main)
                    )
                )
            ) {
                Text("Tap to search domains")
            }
        }
    }
}
