// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import FeatureCryptoDomainDomain
import SwiftUI

// MARK: - Type

enum SearchCryptoDomainRoute: NavigationRoute {

    case checkout

    @ViewBuilder
    func destination(in store: Store<SearchCryptoDomainState, SearchCryptoDomainAction>) -> some View {
        switch self {
        case .checkout:
            // TODO: replace with checkout screen
            EmptyView()
        }
    }
}

enum SearchCryptoDomainAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<SearchCryptoDomainRoute>?)
    case binding(BindingAction<SearchCryptoDomainState>)
}

// MARK: - Properties

struct SearchCryptoDomainState: Equatable, NavigationState {

    @BindableState var searchText: String
    @BindableState var isSearchFieldSelected: Bool
    @BindableState var isAlertCardShown: Bool
    @BindableState var searchResults: [SearchDomainResult]
    var route: RouteIntent<SearchCryptoDomainRoute>?

    init(
        searchText: String = "",
        isSearchFieldSelected: Bool = false,
        isAlertCardShown: Bool = true,
        searchResults: [SearchDomainResult] = [
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
        ],
        route: RouteIntent<SearchCryptoDomainRoute>? = nil
    ) {
        self.searchText = searchText
        self.isSearchFieldSelected = isSearchFieldSelected
        self.isAlertCardShown = isAlertCardShown
        self.searchResults = searchResults
        self.route = route
    }
}

struct SearchCryptoDomainEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>

    init(mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.mainQueue = mainQueue
    }
}

let searchCryptoDomainReducer = Reducer<
    SearchCryptoDomainState,
    SearchCryptoDomainAction,
    SearchCryptoDomainEnvironment
> { state, action, environment in
    switch action {
    case .route(let route):
        state.route = route
        return .none
    case .binding(.set(\.$isAlertCardShown, false)):
        state.isAlertCardShown = false
        return .none
    case .binding:
        return .none
    }
}
