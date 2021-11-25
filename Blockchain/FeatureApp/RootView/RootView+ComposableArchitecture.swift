//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComponentLibrary
import ComposableArchitecture
import ComposableArchitectureExtensions
import ComposableNavigation
import Localization
import SwiftUI
import ToolKit

struct RootViewState: Equatable, NavigationState {

    var route: RouteIntent<RootViewRoute>?

    @BindableState var tab: Tab = .home
    @BindableState var fab: Bool = false

    var buyAndSell: BuyAndSell = .init()
}

extension RootViewState {

    struct BuyAndSell: Equatable {
        var segment: Int = 0
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
                .ignoresSafeArea()
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
    case .frequentAction(let action):
        state.fab = false
        switch action {
        case .buy:
            state.buyAndSell.segment = 0
            state.tab = .buyAndSell
        case .sell:
            state.buyAndSell.segment = 1
            state.tab = .buyAndSell
        default:
            break
        }
        return .none
    case .route, .binding:
        return .none
    }
}
.binding()
.routing()
.published()
