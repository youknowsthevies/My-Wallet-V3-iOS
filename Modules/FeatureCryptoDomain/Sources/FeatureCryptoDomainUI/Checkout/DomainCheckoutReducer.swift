// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureCryptoDomainDomain
import Foundation
import OrderedCollections
import SwiftUI
import ToolKit

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
    case claimDomain
    case didClaimDomain(Result<EmptyValue, OrderDomainRepositoryError>)
    case returnToBrowseDomains
}

struct DomainCheckoutState: Equatable, NavigationState {
    @BindableState var termsSwitchIsOn: Bool = false
    @BindableState var isRemoveBottomSheetShown: Bool = false
    @BindableState var removeCandidate: SearchDomainResult?
    var selectedDomains: OrderedSet<SearchDomainResult>
    var route: RouteIntent<DomainCheckoutRoute>?

    init(
        selectedDomains: OrderedSet<SearchDomainResult> = OrderedSet([])
    ) {
        self.selectedDomains = selectedDomains
    }
}

struct DomainCheckoutEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let orderDomainRepository: OrderDomainRepositoryAPI
    let userInfoProvider: () -> AnyPublisher<OrderDomainUserInfo, Error>
}

let domainCheckoutReducer = Reducer<
    DomainCheckoutState,
    DomainCheckoutAction,
    DomainCheckoutEnvironment
> { state, action, environment in
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
    case .claimDomain:
        guard let domain = state.selectedDomains.first else {
            return .none
        }
        return environment
            .userInfoProvider()
            .ignoreFailure(setFailureType: OrderDomainRepositoryError.self)
            .map { userInfo in
                environment
                    .orderDomainRepository
                    .createDomainOrder(
                        isFree: true,
                        domainName: domain.domainName.replacingOccurrences(of: ".blockchain", with: ""),
                        walletAddress: userInfo.ethereumAddress,
                        nabuUserId: userInfo.nabuUserId
                    )
            }
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                switch result {
                case .success:
                    return .didClaimDomain(.success(.noValue))
                case .failure(let error):
                    return .didClaimDomain(.failure(error))
                }
            }

    case .didClaimDomain(let result):
        switch result {
        case .success:
            return .navigate(to: .confirmation)
        case .failure(let error):
            print(error.localizedDescription)
            return .none
        }

    case .returnToBrowseDomains:
        return .none
    }
}
.debug()
.binding()
.routing()
