// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureInterestDomain
import PlatformKit
import PlatformUIKit
import SwiftUI
import UIComponentsKit

struct InterestNoEligibleWalletsView: View {

    private let store: Store<InterestNoEligibleWalletsState, InterestNoEligibleWalletsAction>

    init(store: Store<InterestNoEligibleWalletsState, InterestNoEligibleWalletsAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ActionableView(
                content: {
                    Spacer()
                    VStack(
                        alignment: .center,
                        spacing: Spacing.interItem,
                        content: {
                            Text(viewStore.title)
                                .textStyle(.title)
                            Text(viewStore.description)
                                .textStyle(.subheading)
                                .multilineTextAlignment(.center)
                        }
                    )
                    Spacer()
                },
                buttons: [
                    .init(
                        title: viewStore.action,
                        action: {
                            viewStore.send(.startBuyTapped)
                        }
                    )
                ]
            )
            .onDisappear {
                viewStore.send(.startBuyOnDismissalIfNeeded)
            }
        }
    }
}

struct InterestNoEligibleWalletsView_Previews: PreviewProvider {
    static var previews: some View {
        InterestNoEligibleWalletsView(
            store: .init(
                initialState: .init(
                    interestAccountRate: .init(
                        currencyCode: "BTC",
                        rate: 4.0
                    )
                ),
                reducer: interestNoEligibleWalletsReducer,
                environment: .init()
            )
        )
    }
}
