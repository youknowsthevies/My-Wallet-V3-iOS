// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import OpenBanking
import PlatformUIKit
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

    public var account: OpenBanking.BankAccount
    public var payment: OpenBanking.Payment.Details?

    public enum Action: Equatable {
        case link(institution: OpenBanking.Institution)
        case pay(amountMinor: String, product: String)
    }

    public internal(set) var ui: UI?
    public internal(set) var action: Action

    var bankName: String {
        switch action {
        case .link(let institution):
            return institution.fullName
        case .pay:
            return account.details?.bankName ?? R.Bank.yourBank
        }
    }
}

public enum BankAction: Hashable, FailAction {

    case request

    case createPayment(OpenBanking.BankAccount, amountMinor: String, product: String)
    case waitForApproval(OpenBanking.BankAccount)
    case waitForPaymentApproval(OpenBanking.Payment)

    case launchAuthorisation(URL)

    case updatePayment(OpenBanking.Payment.Details)
    case updateWallet(OpenBanking.BankAccount)

    case success
    case cancel
    case dismiss

    case linked(OpenBanking.BankAccount)
    case authorised(OpenBanking.BankAccount, OpenBanking.Payment.Details)
    case fail(OpenBanking.Error)
}

public let bankReducer = Reducer<BankState, BankAction, OpenBankingEnvironment> { state, action, environment in

    enum ID {
        struct Poll: Hashable {}
        struct LaunchBank: Hashable {}
        struct Linked: Hashable {}
        struct ConsentError: Hashable {}
    }

    switch action {
    case .request:
        state.ui = .communicating(to: state.bankName)
        switch state.action {
        case .link(let institution):
            return try state.account
                .activateBankAccount(with: institution.id, in: environment.openBanking)
                .receive(on: environment.scheduler.main)
                .delay(for: .seconds(0.5), scheduler: environment.scheduler.main)
                .eraseToEffect()
                .mapped(to: BankAction.waitForApproval)
        case .pay(amountMinor: let amount, product: let product):
            return state.account
                .get(in: environment.openBanking)
                .tryMap { try ($0.get(), amountMinor: amount, product: product) }
                .result()
                .receive(on: environment.scheduler.main)
                .delay(for: .seconds(0.5), scheduler: environment.scheduler.main)
                .eraseToEffect()
                .mapped(to: /BankAction.createPayment)
        }

    case .createPayment(let account, let amount, let product):
        state.ui = .communicating(to: state.bankName)
        return try account.pay(amountMinor: amount, product: product, in: environment.openBanking)
            .receive(on: environment.scheduler.main)
            .delay(for: .seconds(0.5), scheduler: environment.scheduler.main)
            .eraseToEffect()
            .mapped(to: BankAction.waitForPaymentApproval)

    case .waitForApproval(let account):
        return try .merge(
            environment.openBanking.state.publisher(for: .authorisation.url, as: URL.self)
                .ignoreResultFailure()
                .receive(on: environment.scheduler.main)
                .eraseToEffect()
                .mapped(to: BankAction.launchAuthorisation)
                .cancellable(id: ID.LaunchBank()),
            account.poll(in: environment.openBanking)
                .receive(on: environment.scheduler.main)
                .eraseToEffect()
                .mapped(to: BankAction.updateWallet)
                .cancellable(id: ID.Poll())
        )

    case .waitForPaymentApproval(let payment):
        return .merge(
            environment.openBanking.state.publisher(for: .authorisation.url, as: URL.self)
                .ignoreResultFailure()
                .receive(on: environment.scheduler.main)
                .eraseToEffect()
                .mapped(to: BankAction.launchAuthorisation)
                .cancellable(id: ID.LaunchBank()),
            payment.poll(in: environment.openBanking)
                .receive(on: environment.scheduler.main)
                .eraseToEffect()
                .mapped(to: BankAction.updatePayment)
                .cancellable(id: ID.Poll())
        )

    case .launchAuthorisation(let url):
        state.ui = .waiting(for: state.bankName)
        return .merge(
            .cancel(id: ID.LaunchBank()),
            .fireAndForget { environment.openURL.open(url) }
        )

    case .updateWallet(let account):
        state.account = account
        if let error = account.error {
            return Effect(value: BankAction.fail(error))
        }
        state.ui = .updatingWallet
        return .merge(
            environment.openBanking.state.publisher(for: .is.authorised, as: Bool.self)
                .ignoreResultFailure()
                .receive(on: environment.scheduler.main)
                .filter { $0 }
                .eraseToEffect()
                .mapped(to: BankAction.success)
                .cancellable(id: ID.Linked()),
            environment.openBanking.state.publisher(for: .consent.error, as: OpenBanking.State.Error.self)
                .ignoreResultFailure()
                .receive(on: environment.scheduler.main)
                .eraseToEffect()
                .map(OpenBanking.Error.init)
                .mapped(to: BankAction.fail)
                .cancellable(id: ID.ConsentError())
        )
    case .updatePayment(let payment):
        state.payment = payment
        if let error = payment.extraAttributes?.error {
            return Effect(value: .fail(.code(error)))
        }
        state.ui = .payment(success: payment)
        return .none

    case .success:
        state.ui = .linked(institution: state.bankName)
        return .none

    case .dismiss:
        return .fireAndForget(environment.dismiss)

    case .linked, .cancel, .authorised:
        return .none

    case .fail(let error):
        state.ui = .error(error)
        return .merge(
            .cancel(id: ID.LaunchBank()),
            .cancel(id: ID.Poll()),
            .cancel(id: ID.Linked()),
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
                    content: {
                        Spacer()
                        InfoView(
                            ui.info,
                            in: .platformUIKit
                        )
                        Spacer()
                    },
                    buttons: ui.action
                        .or(default: [])
                        .enumerated()
                        .map { i, action in
                            let style: ActionableView<
                                TupleView<(Spacer, InfoView, Spacer)>
                            >.ButtonState.Style = i == 0 ? .primary : .secondary
                            switch action {
                            case .ok:
                                return .init(
                                    title: R.Bank.Action.ok,
                                    action: {
                                        if let payment = viewStore.payment {
                                            viewStore.send(.authorised(viewStore.account, payment))
                                        } else {
                                            viewStore.send(.fail(.message(R.Bank.Error.failedToGetPaymentDetails)))
                                        }
                                    },
                                    style: style
                                )
                            case .next:
                                return .init(
                                    title: R.Bank.Action.next,
                                    action: { viewStore.send(.linked(viewStore.account)) },
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
                                    title: R.Bank.Action.cancel,
                                    action: { viewStore.send(.cancel) },
                                    style: style
                                )
                            }
                        }
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

    private typealias ButtonAction = ActionableView<TupleView<(Spacer, InfoView, Spacer)>>.ButtonState

    private func actions(
        from actions: [BankState.UI.Action]?,
        in viewStore: ViewStore<BankState, BankAction>
    ) -> [ButtonAction] {
        guard let actions = actions else { return [] }
        return actions
            .enumerated()
            .map { i, action in
                let style: ButtonAction.Style = i == 0 ? .primary : .secondary
                switch action {
                case .ok:
                    return .init(
                        title: R.Bank.Action.ok,
                        action: {
                            if let payment = viewStore.payment {
                                viewStore.send(.authorised(viewStore.account, payment))
                            } else {
                                viewStore.send(.fail(.message(R.Bank.Error.failedToGetPaymentDetails)))
                            }
                        },
                        style: style
                    )
                case .next:
                    return .init(
                        title: R.Bank.Action.next,
                        action: { viewStore.send(.linked(viewStore.account)) },
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
                        title: R.Bank.Action.cancel,
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
                    account: .mock,
                    ui: .waiting(for: "Monzo"),
                    action: .link(institution: .mock)
                ),
                reducer: bankReducer,
                environment: .mock
            )
        )
    }
}
#endif
