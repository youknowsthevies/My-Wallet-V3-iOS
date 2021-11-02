// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureWithdrawalLockDomain
import Localization
import SwiftUI
import UIComponentsKit

struct WithdrawalLockState: Hashable, NavigationState {
    var route: RouteIntent<WithdrawalLockRoute>?
    var withdrawalLocks: WithdrawalLocks?
    var amountEventObserverIdToken = "WithdrawalLockState.amountEventObserverIdToken"
}

enum WithdrawalLockAction: Hashable, NavigationAction {
    case loadWithdrawalLocks
    case cleanUp
    case present(withdrawalLocks: WithdrawalLocks?)
    case route(RouteIntent<WithdrawalLockRoute>?)
}

enum WithdrawalLockRoute: NavigationRoute {
    case details(withdrawalLocks: WithdrawalLocks)

    func destination(in store: Store<WithdrawalLockState, WithdrawalLockAction>) -> some View {
        switch self {
        case .details(let withdrawalLocks):
            return WithdrawalLockDetailsView(withdrawalLocks: withdrawalLocks)
        }
    }
}

struct WithdrawalLockEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>

    let withdrawalLockUseCase: WithdrawalLocksUseCaseAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        withdrawalLockUseCase: WithdrawalLocksUseCaseAPI = resolve()
    ) {
        self.mainQueue = mainQueue
        self.withdrawalLockUseCase = withdrawalLockUseCase
    }
}

let withdrawalLockReducer = Reducer<
    WithdrawalLockState,
    WithdrawalLockAction,
    WithdrawalLockEnvironment
> { state, action, environment in

    switch action {
    case .loadWithdrawalLocks:
        return .merge(
            environment.withdrawalLockUseCase
                .withdrawLocks
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map { withdrawalLocks in
                    .present(withdrawalLocks: withdrawalLocks)
                }
                .cancellable(id: state.amountEventObserverIdToken)
        )
    case .cleanUp:
        return .cancel(id: state.amountEventObserverIdToken)
    case .present(withdrawalLocks: let withdrawalLocks):
        state.withdrawalLocks = withdrawalLocks
        return .none
    case .route(let routeItent):
        state.route = routeItent
        return .none
    }
}

public struct WithdrawalLockView: View {

    let store: Store<WithdrawalLockState, WithdrawalLockAction>

    public init() {
        store = .init(
            initialState: .init(withdrawalLocks: nil),
            reducer: withdrawalLockReducer,
            environment: WithdrawalLockEnvironment()
        )
    }

    init(store: Store<WithdrawalLockState, WithdrawalLockAction>) {
        self.store = store
    }

    private typealias LocalizationIds = LocalizationConstants.WithdrawalLock

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
                            .scaleEffect(0.7)
                            .frame(height: 14)
                        Spacer()

                        let amount = viewStore.withdrawalLocks?.amount
                        Text(amount ?? " ")
                            .shimmer(
                                enabled: amount == nil,
                                width: 50
                            )
                    }
                    .foregroundColor(.semantic.body)
                    .typography(.paragraph2)
                    .padding()
                }
                .navigationRoute(in: store)
                Divider()
                    .foregroundColor(.semantic.light)
            }
            .onAppear {
                viewStore.send(.loadWithdrawalLocks)
            }
            .onDisappear {
                viewStore.send(.cleanUp)
            }
        }
    }
}

// swiftlint:disable type_name
struct WithdrawalLockView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WithdrawalLockView(store:
                .init(
                    initialState: .init(withdrawalLocks: nil),
                    reducer: withdrawalLockReducer,
                    environment: WithdrawalLockEnvironment()
                )
            )
        }
    }
}
