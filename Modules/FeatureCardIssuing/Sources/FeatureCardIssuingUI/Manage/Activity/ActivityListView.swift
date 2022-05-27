// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI

struct ActivityListView: View {

    let localized = LocalizationConstants.CardIssuing.Manage.Activity.self
    let store: Store<CardManagementState, CardManagementAction>

    init(
        store: Store<CardManagementState, CardManagementAction>
    ) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store.scope(state: \.transactions)) { viewStore in
            ScrollView {
                ForEach(viewStore.state) { transaction in
                    ActivityRow(transaction) {
                        viewStore.send(.showTransaction(transaction))
                    }
                    PrimaryDivider()
                }
            }
            .padding(0)
            .navigationTitle(localized.transactionListTitle)
        }
    }
}

#if DEBUG

struct ActivityList_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            ActivityListView(
                store: Store(
                    initialState: .preview,
                    reducer: cardManagementReducer,
                    environment: .preview
                )
            )
        }
    }
}

#endif
