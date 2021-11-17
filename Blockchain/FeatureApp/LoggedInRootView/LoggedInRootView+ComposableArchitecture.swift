//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import SwiftUI

struct LoggedInRootState: Equatable, NavigationState {

    var route: RouteIntent<LoggedInRootRoute>?

    @BindableState var tab: Tab = .home
    @BindableState var fab: Bool = false
}

enum LoggedInRootAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<LoggedInRootRoute>?)
    case select(Tab)
    case binding(BindingAction<LoggedInRootState>)
}

enum LoggedInRootRoute: NavigationRoute {

    case account
    case QR

    @ViewBuilder func destination(in store: Store<LoggedInRootState, LoggedInRootAction>) -> some View {
        switch self {
        case .QR:
            Text("QR")
        case .account:
            Text("Account")
        }
    }
}

struct LoggedInRootEnvironment {}

let loggedInRootReducer = Reducer<
    LoggedInRootState,
    LoggedInRootAction,
    LoggedInRootEnvironment
> { state, action, _ in
    switch action {
    case .select(let tab):
        state.tab = tab
        return .none
    case .route, .binding:
        return .none
    }
}
.binding()
.routable()
