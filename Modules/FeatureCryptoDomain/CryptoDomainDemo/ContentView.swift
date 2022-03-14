// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
@testable import FeatureCryptoDomainData
@testable import FeatureCryptoDomainMock
@testable import FeatureCryptoDomainUI
import SwiftUI

struct ContentView: View {

    @State var claimFlowShown = false

    var body: some View {
        VStack {
            Button("Let's claim a domain!") {
                claimFlowShown.toggle()
            }
        }
        .sheet(isPresented: $claimFlowShown) {
            ClaimIntroductionView(
                store: .init(
                    initialState: .init(),
                    reducer: claimIntroductionReducer,
                    environment: .init(
                        mainQueue: .main,
                        searchDomainRepository: SearchDomainRepository(
                            apiClient: SearchDomainClient.mock
                        ),
                        orderDomainRepository: OrderDomainRepository(
                            apiClient: OrderDomainClient.mock
                        ),
                        userInfoProvider: {
                            .just(
                                OrderDomainUserInfo(
                                    nabuUserId: "mockUserId",
                                    nabuUserName: "Firstname",
                                    ethereumAddress: "mockAddress"
                                )
                            )
                        }
                    )
                )
            )
        }
    }
}
