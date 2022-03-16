// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
@testable import FeatureCryptoDomainUI
import SwiftUI

struct ContentView: View {
    var body: some View {
        PrimaryNavigationView {
            PrimaryNavigationLink(
                destination: ClaimIntroductionView(
                    store: .init(
                        initialState: .init(),
                        reducer: claimIntroductionReducer,
                        environment: ()
                    )
                )
            ) {
                Text("Let's claim a domain!")
            }
        }
    }
}
