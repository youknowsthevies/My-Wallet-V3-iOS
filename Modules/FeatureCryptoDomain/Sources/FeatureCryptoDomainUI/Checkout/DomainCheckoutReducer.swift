// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import FeatureCryptoDomainDomain
import OrderedCollections
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
    case removeDomain(SearchDomainResult)
}

struct DomainCheckoutState: Equatable, NavigationState {
    @BindableState var termsSwitchIsOn: Bool = false
    var selectedDomains: OrderedSet<SearchDomainResult> = OrderedSet([])
    var route: RouteIntent<DomainCheckoutRoute>?
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
    case .removeDomain(let domain):
        state.selectedDomains.remove(domain)
        return .none
    }
}
.binding()
.routing()
