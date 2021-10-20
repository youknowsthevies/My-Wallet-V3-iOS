// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import OpenBanking
import SwiftUI
import UIComponentsKit

public struct ApproveState: Equatable, NavigationState {

    public struct UI: Codable, Hashable {
        public var title: String
        public var tasks: [Task]
    }

    public var route: RouteIntent<ApproveRoute>?
    public var bank: BankState
    public var ui: UI

    init(bank: BankState) {
        self.bank = bank
        ui = .model(bank.account, for: bank.action)
    }
}

public enum ApproveAction: NavigationAction {

    case route(RouteIntent<ApproveRoute>?)

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
                if viewStore.ui.tasks.isEmpty {
                    InfoView(
                        .init(
                            media: .bankIcon,
                            overlay: .init(media: .error),
                            title: R.Error.title,
                            subtitle: R.Error.subtitle
                        ),
                        in: .platformUIKit
                    )
                } else {
                    VStack {
                        ScrollView(showsIndicators: false) {
                            ForEach(viewStore.ui.tasks, id: \.self, content: TaskView.init)
                            actionArea
                                .hidden()
                        }
                        .overlay(actionArea, alignment: .bottom)
                    }
                }
            }
            .navigationTitle(viewStore.bank.account.attributes.entity)
            .navigationRoute(in: store)
            .whiteNavigationBarStyle()
            .trailingNavigationButton(.close) {
                viewStore.send(.dismiss)
            }
        }
    }

    @ViewBuilder var actionArea: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 12.pt.in(.screen)) {
                Button(R.Approve.Action.approve) {
                    viewStore.send(.approve)
                }
                .buttonStyle(PrimaryButtonStyle())
                Button(R.Approve.Action.deny) {
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
                        bank: .init(account: .mock, action: .link(institution: .mock))
                    ),
                    reducer: approveReducer,
                    environment: .mock
                )
            )
        }
    }
}
#endif
