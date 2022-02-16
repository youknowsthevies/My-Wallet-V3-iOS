// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
@testable import FeatureCryptoDomainUI
@testable import FeatureCryptoDomainDomain
import SwiftUI

struct ContentView: View {
    var body: some View {
        PrimaryNavigationView {
            PrimaryNavigationLink(
                destination: SearchCryptoDomainView(
                    store: .init(
                        initialState: .init(
                            searchResults: [
                               SearchDomainResult(
                                   domainName: "cocacola.blockchain",
                                   domainType: .premium,
                                   domainAvailability: .unavailable
                               ),
                               SearchDomainResult(
                                   domainName: "cocacola001.blockchain",
                                   domainType: .free,
                                   domainAvailability: .availableForFree
                               ),
                               SearchDomainResult(
                                   domainName: "cocola.blockchain",
                                   domainType: .premium,
                                   domainAvailability: .availableForPremiumSale(price: "50")
                               )
                           ]
                        ),
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
