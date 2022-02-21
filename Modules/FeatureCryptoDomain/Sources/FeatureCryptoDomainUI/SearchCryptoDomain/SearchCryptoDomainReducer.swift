// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import FeatureCryptoDomainDomain
import OrderedCollections
import SwiftUI
import ToolKit

// MARK: - Type

enum SearchCryptoDomainRoute: NavigationRoute {

    case checkout

    @ViewBuilder
    func destination(in store: Store<SearchCryptoDomainState, SearchCryptoDomainAction>) -> some View {
        switch self {
        case .checkout:
            IfLetStore(
                store.scope(
                    state: \.checkoutState,
                    action: SearchCryptoDomainAction.checkoutAction
                ),
                then: DomainCheckoutView.init(store:)
            )
        }
    }
}

enum SearchCryptoDomainAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<SearchCryptoDomainRoute>?)
    case binding(BindingAction<SearchCryptoDomainState>)
    case selectFreeDomain(SearchDomainResult)
    case selectPremiumDomain(SearchDomainResult)
    case openPremiumDomainLink(URL)
    case checkoutAction(DomainCheckoutAction)
}

// MARK: - Properties

struct SearchCryptoDomainState: Equatable, NavigationState {

    @BindableState var searchText: String
    @BindableState var isSearchFieldSelected: Bool
    @BindableState var isAlertCardShown: Bool
    @BindableState var isPremiumDomainBottomSheetShown: Bool
    @BindableState var selectedPremiumDomain: SearchDomainResult?
    var searchResults: [SearchDomainResult]
    var filteredSearchResults: [SearchDomainResult]
    var selectedDomains: OrderedSet<SearchDomainResult>
    var route: RouteIntent<SearchCryptoDomainRoute>?
    var checkoutState: DomainCheckoutState?

    init(
        searchText: String = "",
        isSearchFieldSelected: Bool = false,
        isAlertCardShown: Bool = true,
        isPremiumDomainBottomSheetShown: Bool = false,
        selectedPremiumDomain: SearchDomainResult? = nil,
        searchResults: [SearchDomainResult] = [],
        route: RouteIntent<SearchCryptoDomainRoute>? = nil,
        checkoutState: DomainCheckoutState? = nil
    ) {
        self.searchText = searchText
        self.isSearchFieldSelected = isSearchFieldSelected
        self.isAlertCardShown = isAlertCardShown
        self.isPremiumDomainBottomSheetShown = isPremiumDomainBottomSheetShown
        self.selectedPremiumDomain = selectedPremiumDomain
        self.searchResults = searchResults
        filteredSearchResults = searchResults
        selectedDomains = OrderedSet([])
        self.route = route
        self.checkoutState = checkoutState
    }
}

struct SearchCryptoDomainEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>

    init(mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.mainQueue = mainQueue
    }
}

let searchCryptoDomainReducer = Reducer.combine(
    domainCheckoutReducer
        .optional()
        .pullback(
            state: \.checkoutState,
            action: /SearchCryptoDomainAction.checkoutAction,
            environment: { _ in () }
        ),
    Reducer<
        SearchCryptoDomainState,
        SearchCryptoDomainAction,
        SearchCryptoDomainEnvironment
    > { state, action, _ in
        switch action {
        case .binding(.set(\.$isPremiumDomainBottomSheetShown, false)):
            state.selectedPremiumDomain = nil
            return .none

        case .binding:
            return .none

        case .selectFreeDomain(let domain):
            state.selectedDomains.removeAll()
            state.selectedDomains.append(domain)
            return Effect(value: .navigate(to: .checkout))

        case .selectPremiumDomain(let domain):
            state.selectedPremiumDomain = domain
            return Effect(value: .set(\.$isPremiumDomainBottomSheetShown, true))

        case .openPremiumDomainLink(let url):
            // TODO: remove this and use ExternalAppOpener when integrated with main target
            UIApplication.shared.open(url)
            return .none

        case .route(let route):
            if let routeValue = route?.route {
                switch routeValue {
                case .checkout:
                    state.checkoutState = .init(
                        selectedDomains: state.selectedDomains
                    )
                }
            }
            return .none

        case .checkoutAction(.removeDomain(let domain)):
            state.selectedDomains.remove(domain)
            return .none

        case .checkoutAction:
            return .none
        }
    }
    .routing()
    .binding()
)
