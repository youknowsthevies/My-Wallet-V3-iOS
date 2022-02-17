// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import OrderedCollections
import ComposableArchitecture
import ComposableNavigation
import FeatureCryptoDomainDomain
import SwiftUI

enum DomainCheckoutRoute: NavigationRoute {
    case confirmation

    @ViewBuilder
    func destination(in store: Store<DomainCheckoutState, DomainCheckoutAction>) -> some View {
        switch self {
        case .confirmation:
            EmptyView()
        }
    }
}

enum DomainCheckoutAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<DomainCheckoutRoute>?)
    case binding(BindingAction<DomainCheckoutState>)
}

struct DomainCheckoutState: Equatable, NavigationState {
    @BindableState var termsSwitchIsOn: Bool = false
    var route: RouteIntent<DomainCheckoutRoute>?
    var selectedDomains: OrderedSet<SearchDomainResult> = OrderedSet([])
}

let domainCheckoutReducer = Reducer<
    DomainCheckoutState,
    DomainCheckoutAction,
    Void
> { state, action, _ in
    switch action {
    case .route:
        return .none
    case .binding:
        return .none
    }
}
.binding()
.routing()
