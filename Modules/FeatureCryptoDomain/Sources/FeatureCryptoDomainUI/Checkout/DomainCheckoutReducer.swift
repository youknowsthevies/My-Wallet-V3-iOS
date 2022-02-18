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
    var selectedDomains: OrderedSet<SearchDomainResult> = OrderedSet([
        SearchDomainResult(
            domainName: "cocacola.blockchain",
            domainType: .premium,
            domainAvailability: .unavailable
        ),
        SearchDomainResult(
            domainName: "cocacola001.blockchain",
            domainType: .free,
            domainAvailability: .availableForFree
        ),
        SearchDomainResult(
            domainName: "cocola.blockchain",
            domainType: .premium,
            domainAvailability: .availableForPremiumSale(price: "50")
        )
    ])
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
