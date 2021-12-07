//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
#if canImport(SharedComponentLibrary)
import SharedComponentLibrary
#else
import ComponentLibrary
#endif
import ComposableArchitecture
import ComposableArchitectureExtensions
import ComposableNavigation
import Localization
import SwiftUI
import ToolKit

struct RootViewState: Equatable, NavigationState {

    var route: RouteIntent<RootViewRoute>?

    @BindableState var tab: Tab = .home
    @BindableState var fab: FrequentAction

    @BindableState var buyAndSell: BuyAndSell = .init()
}

extension RootViewState {

    struct BuyAndSell: Equatable {

        var segment: Int = 0
    }

    struct FrequentAction: Equatable {
        var isOn: Bool = false
        var animate: Bool
    }
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
            QRCodeScannerView()
                .identity(blockchain.ux.user.scan.qr)
                .ignoresSafeArea()
        case .account:
            AccountView()
                .identity(blockchain.ux.user.account)
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
        state.fab.isOn = false
        return .none
    case .binding(.set(\.$fab.isOn, true)):
        state.fab.animate = false
        return .none
    case .route, .binding:
        return .none
    }
}
.binding()
.routing()
.published()
