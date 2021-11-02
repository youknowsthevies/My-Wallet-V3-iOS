// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import OpenBanking
import Session
import SwiftUI
import ToolKit
import UIComponentsKit

public struct BankState: Equatable {

    public struct UI: Equatable {

        public enum Action: Hashable {
            case retry(label: String, action: BankAction)
            case next
            case ok
            case cancel
        }

        public let info: InfoView.Model
        public internal(set) var action: [Action]?
    }

    public internal(set) var ui: UI?
    public internal(set) var action: OpenBanking.Action

    var account: OpenBanking.BankAccount {
        action.account
    }

    var bankName: String {
        switch action.then {
        case .link(let institution):
            return institution.fullName
        case .deposit, .confirm:
            return account.details?.bankName ?? Localization.Bank.yourBank
        }
    }
}

public enum BankAction: Hashable, FailureAction {
    case request
    case launchAuthorisation(URL)
    case finalise(OpenBanking.Success)
    case cancel
    case dismiss
    case finished
    case failure(OpenBanking.Error)
}

public let bankReducer = Reducer<BankState, BankAction, OpenBankingEnvironment> { state, action, environment in

    enum ID {
        struct OB: Hashable {}
        struct ConsentError: Hashable {}
    }

    switch action {
    case .request:
        state.ui = .communicating(to: state.bankName)
        return environment.openBanking.start(action: state.action)
            .compactMap { state in
                switch state {
                case .success(let output):
                    return BankAction.finalise(output)
                case .failure(let error):
                    return BankAction.failure(error)
                case .launchAuthorisation(let url):
                    return BankAction.launchAuthorisation(url)
                }
            }
            .eraseToEffect()
            .cancellable(id: ID.OB())
        
    case .launchAuthorisation(let url):
        state.ui = .waiting(for: state.bankName)
        return .merge(
            .fireAndForget { environment.openURL.open(url) },
            environment.openBanking.state.publisher(for: .consent.error, as: OpenBanking.Error.self)
                .ignoreResultFailure()
                .receive(on: environment.scheduler.main)
                .eraseToEffect()
                .map(OpenBanking.Error.init)
                .mapped(to: BankAction.failure)
                .cancellable(id: ID.ConsentError())
        )

    case .finalise(let output):
        switch output {
        case .link:
            state.ui = .linked(institution: state.bankName)
        case .deposit(let payment):
            state.ui = .payment(success: payment, in: environment)
        case .confirm:
            fatalError()
        }
        return .cancel(id: ID.OB())
        
    case .dismiss:
        return .fireAndForget(environment.dismiss)

    case .finished, .cancel:
        return .none

    case .failure(let error):
        state.ui = .error(error)
        return .merge(
            .cancel(id: ID.OB()),
            .cancel(id: ID.ConsentError())
        )
    }
}

public struct BankView: View {

    private let store: Store<BankState, BankAction>

    public init(store: Store<BankState, BankAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            if let ui = viewStore.ui {
                ActionableView(
                    ui.info,
                    buttons: buttons(from: ui.action, in: viewStore),
                    in: .openBanking
                )
                .trailingNavigationButton(.close) {
                    viewStore.send(.dismiss)
                }
            } else {
                ProgressView(value: 0.25)
                    .progressViewStyle(IndeterminateProgressStyle())
                    .onAppear {
                        viewStore.send(.request)
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
        .whiteNavigationBarStyle()
    }

    private typealias ButtonState = ActionableView<
        TupleView<(Spacer, InfoView, Spacer)>
    >.ButtonState

    private func buttons(
        from actions: [BankState.UI.Action]?,
        in viewStore: ViewStore<BankState, BankAction>
    ) -> [ButtonState] {
        guard let actions = actions else { return [] }
        return actions
            .enumerated()
            .map { i, action in
                let style: ButtonState.Style = i == 0 ? .primary : .secondary
                switch action {
                case .ok:
                    return .init(
                        title: Localization.Bank.Action.ok,
                        action: { viewStore.send(.finished) },
                        style: style
                    )
                case .next:
                    return .init(
                        title: Localization.Bank.Action.next,
                        action: { viewStore.send(.finished) },
                        style: style
                    )
                case .retry(let label, let action):
                    return .init(
                        title: label,
                        action: { viewStore.send(action) },
                        style: style
                    )
                case .cancel:
                    return .init(
                        title: Localization.Bank.Action.cancel,
                        action: { viewStore.send(.cancel) },
                        style: style
                    )
                }
            }
    }
}

#if DEBUG
struct BankView_Previews: PreviewProvider {

    static var previews: some View {
        BankView(
            store: .init(
                initialState: BankState(
                    ui: .linked(institution: "Monzo"),
                    action: .init(account: .mock, then: .link(institution: .mock))
                ),
                reducer: bankReducer,
                environment: .mock
            )
        )
    }
}
#endif
