//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComponentLibrary
import ComposableArchitecture
import ComposableArchitectureExtensions
import ComposableNavigation
import Localization
import SwiftUI

struct LoggedInRootState: Equatable, NavigationState {

    var route: RouteIntent<LoggedInRootRoute>?

    @BindableState var tab: Tab = .home
    @BindableState var fab: Bool = false
}

enum LoggedInRootAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<LoggedInRootRoute>?)
    case tab(Tab)
    case frequentAction(FrequentAction)
    case binding(BindingAction<LoggedInRootState>)
}

enum LoggedInRootRoute: NavigationRoute {

    case account
    case QR

    @ViewBuilder func destination(in store: Store<LoggedInRootState, LoggedInRootAction>) -> some View {
        switch self {
        case .QR:
            PrimaryNavigationView {
                WithViewStore(store.stateless) { viewStore in
                    QRCodeScannerView()
                        .primaryNavigation(title: LocalizationConstants.scanQRCode) {
                            IconButton(icon: .closeCirclev2) {
                                viewStore.send(.route(nil))
                            }
                        }
                }
            }
        case .account:
            AccountView()
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

struct LoggedInRootEnvironment: PublishedEnvironment {
    var subject: PassthroughSubject<(state: LoggedInRootState, action: LoggedInRootAction), Never> = .init()
}

let loggedInRootReducer = Reducer<
    LoggedInRootState,
    LoggedInRootAction,
    LoggedInRootEnvironment
> { state, action, _ in
    switch action {
    case .tab(let tab):
        state.tab = tab
        return .none
    case .frequentAction:
        state.fab = false
        return .none
    case .route, .binding:
        return .none
    }
}
.binding()
.routing()
.published()
