// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import FeatureCryptoDomainDomain
import Localization
import SwiftUI
import ToolKit

// MARK: - ComposableArchitecture

enum ClaimIntroductionRoute: NavigationRoute {
    case benefits
    case searchDomain

    @ViewBuilder
    func destination(in store: Store<ClaimIntroductionState, ClaimIntroductionAction>) -> some View {
        switch self {
        case .benefits:
            ClaimBenefitsView()
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

enum ClaimIntroductionAction: NavigationAction {
    case route(RouteIntent<ClaimIntroductionRoute>?)
    case searchAction(SearchCryptoDomainAction)
}

struct ClaimIntroductionState: NavigationState {
    var route: RouteIntent<ClaimIntroductionRoute>?
    var searchState: SearchCryptoDomainState?
}

struct ClaimIntroductionEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let searchDomainRepository: SearchDomainRepositoryAPI
}

let claimIntroductionReducer = Reducer.combine(
    searchCryptoDomainReducer
        .optional()
        .pullback(
            state: \.searchState,
            action: /ClaimIntroductionAction.searchAction,
            environment: {
                SearchCryptoDomainEnvironment(
                    mainQueue: $0.mainQueue,
                    searchDomainRepository: $0.searchDomainRepository
                )
            }
        ),
    Reducer<ClaimIntroductionState, ClaimIntroductionAction, ClaimIntroductionEnvironment> {
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
    private typealias Accessibility = AccessibilityIdentifiers.HowItWorks

    private let store: Store<ClaimIntroductionState, ClaimIntroductionAction>

    init(store: Store<ClaimIntroductionState, ClaimIntroductionAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center, spacing: Spacing.padding3) {
                introductionHeader
                    .padding([.top, .leading, .trailing], Spacing.padding3)
                introductionList
                Spacer()
                SmallMinimalButton(title: LocalizedString.promptButton) {
                    viewStore.send(.enter(into: .benefits))
                }
                .accessibility(identifier: Accessibility.smallButton)
                Spacer()
                Text(LocalizedString.instruction)
                    .typography(.caption1)
                    .foregroundColor(.semantic.overlay)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], Spacing.padding3)
                    .accessibility(identifier: Accessibility.instructionText)
                PrimaryButton(title: LocalizedString.goButton) {
                    viewStore.send(.navigate(to: .searchDomain))
                }
                .padding([.leading, .trailing], Spacing.padding3)
                .accessibility(identifier: Accessibility.ctaButton)
            }
            .navigationRoute(in: store)
            .primaryNavigation(title: LocalizedString.title)
        }
    }

    private var introductionHeader: some View {
        VStack(alignment: .center, spacing: Spacing.padding2) {
            Text(LocalizedString.Header.title)
                .typography(.title3)
                .accessibility(identifier: Accessibility.headerTitle)
            Text(LocalizedString.Header.description)
                .typography(.paragraph1)
                .foregroundColor(.semantic.overlay)
                .multilineTextAlignment(.center)
                .accessibility(identifier: Accessibility.headerDescription)
        }
    }

    private var introductionList: some View {
        VStack(alignment: .leading, spacing: 0) {
            PrimaryDivider()
            PrimaryRow(
                title: LocalizedString.ListView.ChooseDomain.title,
                subtitle: LocalizedString.ListView.ChooseDomain.description,
                leading: {
                    Image("number-one")
                        .resizable()
                        .frame(width: 24, height: 24)
                },
                trailing: { EmptyView() }
            ).padding([.top, .bottom], 10)
            PrimaryDivider()
            PrimaryRow(
                title: LocalizedString.ListView.ClaimDomain.title,
                subtitle: LocalizedString.ListView.ClaimDomain.description,
                leading: {
                    Image("number-two")
                        .resizable()
                        .frame(width: 24, height: 24)
                },
                trailing: { EmptyView() }
            ).padding([.top, .bottom], 10)
            PrimaryDivider()
            PrimaryRow(
                title: LocalizedString.ListView.ReceiveCrypto.title,
                subtitle: LocalizedString.ListView.ReceiveCrypto.description,
                leading: {
                    Image("number-three")
                        .resizable()
                        .frame(width: 24, height: 24)
                },
                trailing: { EmptyView() }
            ).padding([.top, .bottom], 10)
            PrimaryDivider()
        }
        .accessibility(identifier: Accessibility.introductionList)
    }
}

#if DEBUG
@testable import FeatureCryptoDomainData
@testable import FeatureCryptoDomainMock

struct ClaimIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        ClaimIntroductionView(
            store: .init(
                initialState: .init(),
                reducer: claimIntroductionReducer,
                environment: .init(
                    mainQueue: .main,
                    searchDomainRepository: SearchDomainRepository(
                        apiClient: SearchDomainClient.mock
                    )
                )
            )
        )
    }
}
#endif
