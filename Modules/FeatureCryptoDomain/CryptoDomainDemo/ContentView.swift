// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
@testable import FeatureCryptoDomainUI
@testable import FeatureCryptoDomainData
@testable import FeatureCryptoDomainMock
import SwiftUI

struct ContentView: View {
    var body: some View {
        PrimaryNavigationView {
            PrimaryNavigationLink(
                destination: ClaimIntroductionView(
                    store: .init(
                        initialState: .init(),
                        reducer: claimIntroductionReducer,
                        environment: .init(
                            mainQueue: .main,
                            searchDomainRepository: SearchDomainRepository(
                                apiClient: MockSearchDomainClient()
                            )
                        )
                    )
                )
            ) {
                Text("Let's claim a domain!")
            }
        }
    }
}
