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
        let viewStore = ViewStore(store)
        switch self {
        case .confirmation:
            if let selectedDomain = viewStore.selectedDomains.first {
                DomainCheckoutConfirmationView(
                    domain: selectedDomain
                )
            }
        }
    }
}

enum DomainCheckoutAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<DomainCheckoutRoute>?)
    case binding(BindingAction<DomainCheckoutState>)
    case removeDomain(SearchDomainResult?)
    case returnToBrowseDomains
}

struct DomainCheckoutState: Equatable, NavigationState {
    @BindableState var termsSwitchIsOn = false
    @BindableState var isRemoveBottomSheetShown = false
    @BindableState var removeCandidate: SearchDomainResult?
    var selectedDomains: OrderedSet<SearchDomainResult>
    var route: RouteIntent<DomainCheckoutRoute>?

    init(
        selectedDomains: OrderedSet<SearchDomainResult> = OrderedSet([])
    ) {
        self.selectedDomains = selectedDomains
    }
}

let domainCheckoutReducer = Reducer<
    DomainCheckoutState,
    DomainCheckoutAction,
    Void
> { state, action, _ in
    switch action {
    case .route:
        return .none
    case .binding(\.$removeCandidate):
        return Effect(value: .set(\.$isRemoveBottomSheetShown, true))
    case .binding(.set(\.$isRemoveBottomSheetShown, false)):
        state.removeCandidate = nil
        return .none
    case .binding:
        return .none
    case .removeDomain(let domain):
        guard let domain = domain else {
            return .none
        }
        state.selectedDomains.remove(domain)
        return Effect(value: .set(\.$isRemoveBottomSheetShown, false))
    case .returnToBrowseDomains:
        return .none
    }
}
.binding()
.routing()
