// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureCryptoDomainUI
import BlockchainComponentLibrary
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
