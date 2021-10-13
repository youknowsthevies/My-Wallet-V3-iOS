// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import FeatureInterestDomain
import Localization
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit

struct InterestAccountListState: Equatable, NavigationState {
    var route: RouteIntent<InterestAccountListRoute>?
    var interestAccountOverviews: [InterestAccountOverview] = []
    var interestAccountDetails: IdentifiedArrayOf<InterestAccountDetails> = []
    var interestAccountDetailsState: InterestAccountDetailsState?
    var loadingInterestAccountList: Bool = false
    var loadingErrorAlert: AlertState<InterestAccountListAction>?
}

struct InterestAccountListView: View {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.Overview

    let store: Store<InterestAccountListState, InterestAccountListAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    ForEachStore(
                        store.scope(
                            state: \.interestAccountDetails,
                            action: InterestAccountListAction.interestAccountButtonTapped
                        )
                    ) { cellStore in
                        InterestAccountListItem(store: cellStore)
                    }
                }
                .whiteNavigationBarStyle()
                .listStyle(PlainListStyle())
                .navigationTitle(LocalizationId.title)
                .navigationBarTitleDisplayMode(.inline)
                .navigationRoute(in: store)
            }
            .onAppear {
                viewStore.send(.loadInterestAccounts)
            }
        }
    }
}

struct InterestAccountListView_Previews: PreviewProvider {

    static var testCurrencyPairs = [
        InterestAccountDetails(
            ineligibilityReason: .eligible,
            currency: .crypto(.coin(.bitcoin)),
            balance: MoneyValue.create(major: "12.0", currency: .crypto(.coin(.bitcoin)))!,
            interestEarned: MoneyValue.create(major: "12.0", currency: .crypto(.coin(.bitcoin)))!,
            rate: 8.0
        )
    ]

    static var previews: some View {
        InterestAccountListView(
            store: .init(
                initialState: InterestAccountListState(
                    interestAccountDetails: .init(uniqueElements: testCurrencyPairs),
                    loadingInterestAccountList: false
                ),
                reducer: interestAccountListReducer,
                environment: .init(
                    fiatCurrencyService: NoOpFiatCurrencyPublisher(),
                    accountOverviewRepository: NoOpInterestAccountOverviewRepository(),
                    accountBalanceRepository: NoOpInterestAccountBalanceRepository(),
                    accountRepository: NoOpBlockchainAccountRepository(),
                    priceService: NoOpPriceService(),
                    mainQueue: .main
                )
            )
        )
    }
}
