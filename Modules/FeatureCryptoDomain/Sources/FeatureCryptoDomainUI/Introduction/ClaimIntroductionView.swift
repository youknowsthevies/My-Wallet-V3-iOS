// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI

// MARK: - ComposableArchitecture

enum ClaimIntroductionRoute: NavigationRoute {
    case benefits
    case searchDomain

    @ViewBuilder
    func destination(in store: Store<ClaimIntroductionState, ClaimIntroductionAction>) -> some View {
        switch self {
        case .benefits:
            EmptyView()
        case .searchDomain:
            IfLetStore(
                store.scope(
                    state: \.searchState,
                    action: ClaimIntroductionAction.searchAction
                ),
                then: SearchCryptoDomainView.init(store:)
            )
        }
    }
}

struct ClaimIntroductionState: NavigationState {
    var route: RouteIntent<ClaimIntroductionRoute>?
    var searchState: SearchCryptoDomainState?
}

enum ClaimIntroductionAction: NavigationAction {
    case route(RouteIntent<ClaimIntroductionRoute>?)
    case searchAction(SearchCryptoDomainAction)
}

let claimIntroductionReducer = Reducer.combine(
    searchCryptoDomainReducer
        .optional()
        .pullback(
            state: \.searchState,
            action: /ClaimIntroductionAction.searchAction,
            environment: {
                SearchCryptoDomainEnvironment(mainQueue: .main)
            }
        ),
    Reducer<ClaimIntroductionState, ClaimIntroductionAction, Void> {
        state, action, _ in
        switch action {
        case .route(let route):
            if let routeValue = route?.route {
                switch routeValue {
                case .searchDomain:
                    state.searchState = .init()
                case .benefits:
                    break
                }
            }
            return .none
        case .searchAction:
            return .none
        }
    }
    .routing()
)

// MARK: - ClaimIntroductionView

struct ClaimIntroductionView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.ClaimIntroduction

    private let store: Store<ClaimIntroductionState, ClaimIntroductionAction>

    init(store: Store<ClaimIntroductionState, ClaimIntroductionAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center, spacing: Spacing.padding3) {
                introductionHeader
                    .padding([.top, .leading, .trailing], Spacing.padding3)
                Spacer()
                SmallMinimalButton(title: LocalizedString.promptButton) {
                    viewStore.send(.enter(into: .benefits))
                }
                Spacer()
                Text(LocalizedString.instruction)
                    .typography(.caption1)
                    .foregroundColor(.semantic.overlay)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], Spacing.padding3)
                PrimaryButton(title: LocalizedString.goButton) {
                    viewStore.send(.navigate(to: .searchDomain))
                }
                .padding([.leading, .trailing], Spacing.padding3)
            }
            .navigationRoute(in: store)
            .primaryNavigation(title: LocalizedString.title)
        }
    }

    private var introductionHeader: some View {
        VStack(alignment: .center, spacing: Spacing.padding2) {
            Text(LocalizedString.Header.title)
                .typography(.title3)
            Text(LocalizedString.Header.description)
                .typography(.paragraph1)
                .foregroundColor(.semantic.overlay)
                .multilineTextAlignment(.center)
        }
    }

    private var introductionList: some View {}
}

struct ClaimIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        ClaimIntroductionView(
            store: .init(
                initialState: .init(),
                reducer: claimIntroductionReducer,
                environment: ()
            )
        )
    }
}
