// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import SwiftUI

enum InterestAccountListRoute: NavigationRoute, CaseIterable {

    case details

    @ViewBuilder
    func destination(in store: Store<InterestAccountListState, InterestAccountListAction>) -> some View {
        switch self {
        case .details:
            IfLetStore(
                store.scope(
                    state: \.interestAccountDetailsState,
                    action: InterestAccountListAction.interestAccountDetails
                ),
                then: InterestAccountDetailsView.init(store:)
            )
        }
    }
}
