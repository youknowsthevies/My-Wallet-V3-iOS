// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import ComposableArchitecture
import ComposableArchitectureExtensions
import ComposableNavigation
import DIKit
import FeatureWithdrawalLockDomain
import Localization
import SwiftUI

struct WithdrawalLockInfoState: Hashable, NavigationState {
    var route: RouteIntent<WithdrawalLockInfoRoute>?

    let amountOnHold: String
    let amountAvailable: String
}

enum WithdrawalLockInfoAction: Hashable, NavigationAction {
    case route(RouteIntent<WithdrawalLockInfoRoute>?)
}

enum WithdrawalLockInfoRoute: NavigationRoute {
    case details
    case learnMore

    func destination(in store: Store<WithdrawalLockInfoState, WithdrawalLockInfoAction>) -> some View {
        switch self {
        case .details:
            return Text("Details")
        case .learnMore:
            return Text("Learn More")
        }
    }
}

struct WithdrawalLockInfoEnvironment {
    let withdrawalLockRepository: WithdrawalLocksRepositoryAPI

    init(withdrawalLockRepository: WithdrawalLocksRepositoryAPI = resolve()) {
        self.withdrawalLockRepository = withdrawalLockRepository
    }
}

let withdrawalLockInfoReducer = Reducer<
    WithdrawalLockInfoState,
    WithdrawalLockInfoAction,
    WithdrawalLockInfoEnvironment
> { state, action, _ in

    switch action {
    case .route(let routeItent):
        state.route = routeItent
        return .none
    }
}

struct WithdrawalLockInfoView: View {

    let store: Store<WithdrawalLockInfoState, WithdrawalLockInfoAction>

    private typealias LocalizationIds = LocalizationConstants.WithdrawalLock

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .top) {
                VStack {
                    Icon.pending
                        .body
                        .frame(height: 60)

                    Text(String(format: LocalizationIds.onHoldAmountTitle, viewStore.amountOnHold))
                        .typography(.title3)
                        .padding(.top, 24.pt)

                    Text(LocalizationIds.holdingPeriodDescription)
                        .typography(.paragraph1)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing, .top], 24.pt)

                    Text(LocalizationIds.learnMoreTitle)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.primary)
                        .onTapGesture {
                            viewStore.send(.navigate(to: .learnMore))
                        }
                        .navigationRoute(in: store)
                        .padding()

                    Divider()

                    HStack {
                        Text(LocalizationIds.availableToWithdrawTitle)
                        Spacer()
                        Text(viewStore.amountAvailable)
                    }
                    .foregroundColor(.semantic.body)
                    .typography(.paragraph2)
                    .frame(height: 55)
                    .padding()

                    Divider()

                    SecondaryButton(title: LocalizationIds.seeDetailsButtonTitle) {
                        viewStore.send(.navigate(to: .details))
                    }
                    .navigationRoute(in: store)
                    .padding()

                    PrimaryButton(title: LocalizationIds.confirmButtonTitle) {
                        viewStore.send(.route(nil))
                    }
                    .navigationRoute(in: store)
                    .padding()
                }
                .padding(.top, 70.pt)

                HStack {
                    Spacer()
                    Button {
                        viewStore.send(.route(nil))
                    } label: {
                        Icon.closeCircle
                            .accentColor(.semantic.muted)
                            .frame(height: 24.pt)
                    }
                    .navigationRoute(in: store)
                }
                .padding([.trailing])
            }
        }
    }
}

// swiftlint:disable type_name
struct WithdrawalLockInfoView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WithdrawalLockInfoView(store:
                .init(
                    initialState: .init(
                        amountOnHold: "$199.99",
                        amountAvailable: "$59.00"
                    ),
                    reducer: withdrawalLockInfoReducer,
                    environment: .init()
                )
            )
        }
    }
}
