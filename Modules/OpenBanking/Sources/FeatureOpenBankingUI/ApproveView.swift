// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import FeatureOpenBankingDomain
import SwiftUI
import UIComponentsKit

public struct ApproveState: Equatable, NavigationState {

    public struct UI: Codable, Hashable {
        public var title: String
        public var tasks: [Task]
    }

    public var route: RouteIntent<ApproveRoute>?
    public var bank: BankState
    public var ui: UI?

    init(bank: BankState) {
        self.bank = bank
    }
}

public enum ApproveAction: Hashable, NavigationAction {

    case route(RouteIntent<ApproveRoute>?)

    case onAppear
    case approve
    case deny
    case dismiss

    case bank(BankAction)
}

public enum ApproveRoute: CaseIterable, NavigationRoute {

    case bank

    @ViewBuilder
    public func destination(in store: Store<ApproveState, ApproveAction>) -> some View {
        switch self {
        case .bank:
            BankView(store: store.scope(state: \.bank, action: ApproveAction.bank))
        }
    }
}

public let approveReducer = Reducer<ApproveState, ApproveAction, OpenBankingEnvironment>.combine(
    bankReducer
        .pullback(
            state: \.bank,
            action: /ApproveAction.bank,
            environment: \.environment
        ),
    .init { state, action, environment in
        switch action {
        case .route(let route):
            state.route = route
            return .none
        case .onAppear:
            state.ui = .model(for: state.bank.action, in: environment)
            return .none
        case .approve:
            return .navigate(to: .bank)
        case .dismiss:
            return .fireAndForget(environment.dismiss)
        case .deny, .bank:
            return .none
        }
    }
)

public struct ApproveView: View {

    let store: Store<ApproveState, ApproveAction>

    public init(store: Store<ApproveState, ApproveAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                if let ui = viewStore.ui, !ui.tasks.isEmpty {
                    VStack {
                        ScrollView(showsIndicators: false) {
                            ForEach(ui.tasks, id: \.self, content: TaskView.init)
                            actionArea
                                .hidden()
                        }
                        .overlay(actionArea, alignment: .bottom)
                    }
                } else {
                    InfoView(
                        .init(
                            media: .bankIcon,
                            overlay: .init(media: .error),
                            title: Localization.Error.title,
                            subtitle: Localization.Error.subtitle
                        ),
                        in: .openBanking
                    )
                }
            }
            .navigationTitle(viewStore.bank.account.attributes.entity)
            .navigationRoute(in: store)
            .whiteNavigationBarStyle()
            .trailingNavigationButton(.close) {
                viewStore.send(.dismiss)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

    @ViewBuilder var actionArea: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 12.pt.in(.screen)) {
                Button(Localization.Approve.Action.approve) {
                    viewStore.send(.approve)
                }
                .buttonStyle(PrimaryButtonStyle())
                Button(Localization.Approve.Action.deny) {
                    viewStore.send(.deny)
                }
                .buttonStyle(SecondaryButtonStyle(foregroundColor: Color.red))
            }
            .padding()
            .background(
                Color.white
                    .ignoresSafeArea(edges: [.bottom])
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 0)
            )
        }
    }
}

#if DEBUG
struct ApproveView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            ApproveView(
                store: .init(
                    initialState: .init(
                        bank: .init(action: .init(account: .mock, then: .link(institution: .mock)))
                    ),
                    reducer: approveReducer,
                    environment: .mock
                )
            )
        }
    }
}
#endif
