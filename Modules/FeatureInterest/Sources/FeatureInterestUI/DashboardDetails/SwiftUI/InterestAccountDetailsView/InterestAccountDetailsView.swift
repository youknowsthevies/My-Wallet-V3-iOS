// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureInterestDomain
import Localization
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit

struct InterestAccountDetailsView: View {

    private typealias LocalizationIds = LocalizationConstants.Interest.Screen.AccountDetails
    private let store: Store<InterestAccountDetailsState, InterestAccountDetailsAction>

    @Environment(\.presentationMode) private var presentationMode

    init(store: Store<InterestAccountDetailsState, InterestAccountDetailsAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ActionableView(
                content: {
                    List {
                        if let balance = viewStore.interestAccountBalanceSummary {
                            VStack {
                                HStack {
                                    CurrencyIcon(icon: .image(balance.currency.image))
                                    VStack(spacing: 4.0) {
                                        HStack {
                                            Text(LocalizationIds.rewardsAccount)
                                                .textStyle(.heading)
                                            Spacer()
                                            Text(balance.fiatBalance)
                                                .textStyle(.heading)
                                        }
                                        HStack {
                                            Text(balance.currency.name)
                                                .textStyle(.subheading)
                                            Spacer()
                                            Text(balance.cryptoBalance)
                                                .textStyle(.subheading)
                                        }
                                    }
                                }
                                .padding(
                                    .init(
                                        top: 8.0,
                                        leading: 0.0,
                                        bottom: 8.0,
                                        trailing: 0.0
                                    )
                                )
                            }
                        }
                        ForEachStore(
                            store.scope(
                                state: \.interestAccountRowItems,
                                action: InterestAccountDetailsAction.interestAccountDescriptorTapped(id:action:)
                            )
                        ) { cellStore in
                            InterestAccountDetailsRowItemView(store: cellStore)
                        }
                    }
                },
                buttons: [
                    .init(
                        title: LocalizationIds.withdraw,
                        action: {
                            viewStore.send(.startInterestWithdraw)
                        }
                    ),
                    .init(
                        title: LocalizationIds.deposit,
                        action: {
                            viewStore.send(.startInterestDeposit)
                        },
                        style: .secondary
                    )
                ]
            )
            .trailingNavigationButton(.close) {
                presentationMode.wrappedValue.dismiss()
            }
            .whiteNavigationBarStyle()
            .navigationTitle(LocalizationIds.rewardsSummary)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewStore.send(.loadInterestAccountBalanceInfo)
            }
        }
    }
}

struct InterestAccountDetailsView_Previews: PreviewProvider {

    static let state: InterestAccountDetailsState = .init(
        interestAccountOverview: .init(
            interestAccountEligibility: .init(
                currencyType: .crypto(.coin(.bitcoin)),
                isEligible: true,
                ineligibilityReason: .eligible
            ),
            interestAccountRate: .init(currencyCode: "BTC", rate: 4.9),
            balanceDetails: .init(
                balance: "10000000000",
                pendingInterest: "1000",
                totalInterest: "5000",
                pendingWithdrawal: "5000",
                pendingDeposit: "5000",
                code: "BTC"
            )
        )
    )

    static var previews: some View {
        InterestAccountDetailsView(
            store: .init(
                initialState: state,
                reducer: interestAccountDetailsReducer,
                environment: .default
            )
        )
    }
}
