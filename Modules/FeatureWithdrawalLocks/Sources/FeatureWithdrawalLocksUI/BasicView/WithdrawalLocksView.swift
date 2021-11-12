// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureWithdrawalLocksDomain
import Localization
import SwiftUI
import UIComponentsKit

public struct WithdrawalLocksState: Hashable, NavigationState {
    public var route: RouteIntent<WithdrawalLocksRoute>?
    var withdrawalLocks: WithdrawalLocks?

    public init(route: RouteIntent<WithdrawalLocksRoute>? = nil, withdrawalLocks: WithdrawalLocks? = nil) {
        self.route = route
        self.withdrawalLocks = withdrawalLocks
    }
}

public enum WithdrawalLocksAction: Hashable, NavigationAction {
    case loadWithdrawalLocks
    case present(withdrawalLocks: WithdrawalLocks?)
    case route(RouteIntent<WithdrawalLocksRoute>?)
}

public enum WithdrawalLocksRoute: NavigationRoute {
    case details(withdrawalLocks: WithdrawalLocks)

    public func destination(in store: Store<WithdrawalLocksState, WithdrawalLocksAction>) -> some View {
        switch self {
        case .details(let withdrawalLocks):
            return WithdrawalLocksDetailsView(withdrawalLocks: withdrawalLocks)
        }
    }
}

public struct WithdrawalLocksEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>

    let withdrawalLockService: WithdrawalLocksServiceAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        withdrawalLockService: WithdrawalLocksServiceAPI = resolve()
    ) {
        self.mainQueue = mainQueue
        self.withdrawalLockService = withdrawalLockService
    }
}

public let withdrawalLocksReducer = Reducer<
    WithdrawalLocksState,
    WithdrawalLocksAction,
    WithdrawalLocksEnvironment
> { state, action, environment in

    switch action {
    case .loadWithdrawalLocks:
        return .merge(
            environment.withdrawalLockService
                .withdrawLocks
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map { withdrawalLocks in
                    .present(withdrawalLocks: withdrawalLocks)
                }
        )
    case .present(withdrawalLocks: let withdrawalLocks):
        state.withdrawalLocks = withdrawalLocks
        return .none
    case .route(let routeItent):
        state.route = routeItent
        return .none
    }
}

public struct WithdrawalLocksView: View {

    let store: Store<WithdrawalLocksState, WithdrawalLocksAction>

    public init(store: Store<WithdrawalLocksState, WithdrawalLocksAction>) {
        self.store = store
    }

    private typealias LocalizationIds = LocalizationConstants.WithdrawalLocks

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                Button {
                    if let withdrawalLocks = viewStore.state.withdrawalLocks {
                        viewStore.send(.enter(into: .details(withdrawalLocks: withdrawalLocks)))
                    }
                } label: {
                    HStack {
                        Text(LocalizationIds.onHoldTitle)
                        Icon.questionCircle
                            .accentColor(.semantic.muted)
                            .frame(height: 14)
                        Spacer()

                        let amount = viewStore.withdrawalLocks?.amount
                        Text(amount ?? " ")
                            .shimmer(enabled: amount == nil, width: 50)
                    }
                    .foregroundColor(.semantic.body)
                    .typography(.paragraph2)
                    .padding()
                }
                .navigationRoute(in: store)

                PrimaryDivider()
            }
            .onAppear {
                viewStore.send(.loadWithdrawalLocks)
            }
        }
    }
}

// swiftlint:disable type_name
struct WithdrawalLocksView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WithdrawalLocksView(store:
                .init(
                    initialState: .init(withdrawalLocks: nil),
                    reducer: withdrawalLocksReducer,
                    environment: WithdrawalLocksEnvironment(
                        withdrawalLockService: NoOpWithdrawalLocksService()
                    )
                )
            )
        }
    }
}
