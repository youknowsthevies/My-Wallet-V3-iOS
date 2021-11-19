//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComponentLibrary
import ComposableArchitecture
import ComposableArchitectureExtensions
import ComposableNavigation
import Localization
import SwiftUI

struct RootViewState: Equatable, NavigationState {

    var route: RouteIntent<RootViewRoute>?

    @BindableState var tab: Tab = .home
    @BindableState var fab: Bool = false
}

enum RootViewAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<RootViewRoute>?)
    case tab(Tab)
    case frequentAction(FrequentAction)
    case binding(BindingAction<RootViewState>)
}

enum RootViewRoute: NavigationRoute {

    case account
    case QR

    @ViewBuilder func destination(in store: Store<RootViewState, RootViewAction>) -> some View {
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

struct RootViewEnvironment: PublishedEnvironment {
    var subject: PassthroughSubject<(state: RootViewState, action: RootViewAction), Never> = .init()
}

let rootViewReducer = Reducer<
    RootViewState,
    RootViewAction,
    RootViewEnvironment
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
