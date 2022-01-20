// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CasePaths
import Combine
import CombineSchedulers
import DIKit
import Foundation
import Session
import ToolKit

public final class OpenBanking {

    public typealias State = Session.State<Key>

    public struct Data: Hashable {

        public init(
            account: OpenBanking.BankAccount,
            action: OpenBanking.Data.Action
        ) {
            self.account = account
            self.action = action
        }

        public enum Action: Hashable {
            case link(institution: OpenBanking.Institution)
            case deposit(amountMinor: String, product: String)
            case confirm(order: OpenBanking.Order)
        }

        public let account: OpenBanking.BankAccount
        public let action: Action
    }

    public enum Output: Hashable {
        case linked(OpenBanking.BankAccount, institution: OpenBanking.Institution)
        case deposited(OpenBanking.Payment.Details)
        case confirmed(OpenBanking.Order)
    }

    public enum Action: FailureAction, Hashable {
        case waitingForConsent(Output)
        case success(Output)
        case failure(OpenBanking.Error)
    }

    public private(set) var banking: OpenBankingClientAPI

    public var state: State { banking.state }
    private var scheduler: AnySchedulerOf<DispatchQueue> { banking.scheduler }

    public init(banking: OpenBankingClientAPI) {
        self.banking = banking
    }

    public var authorisationURLPublisher: AnyPublisher<URL, Never> {
        state.publisher(for: .authorisation.url, as: URL.self)
            .ignoreResultFailure()
            .eraseToAnyPublisher()
    }

    public var isAuthorising: Bool {
        state.result(for: .authorisation.url).isSuccess
    }

    public func createBankAccount() -> AnyPublisher<OpenBanking.BankAccount, Error> {
        banking.createBankAccount()
    }

    public func reset() {
        state.transaction { state in
            state.clear(.id)
            state.clear(.callback.path)
            state.clear(.is.authorised)
            state.clear(.authorisation.url)
            state.clear(.account)
            state.clear(.error.code)
            state.clear(.consent.error)
            state.clear(.consent.token)
        }
    }

    public func start(_ data: Data) -> AnyPublisher<Action, Never> {

        let publisher = actionPublisher(data).share()

        switch data.action {
        case .link(let institution):
            return publisher
                .flatMap { [waitForAccountLinking] action -> AnyPublisher<Action, Never> in
                    switch action {
                    case .waitingForConsent:
                        return waitForAccountLinking(data.account, institution, action)
                    default:
                        return Just(action).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        default:
            return publisher
                .flatMap { [waitForConsent] action -> AnyPublisher<Action, Never> in
                    switch action {
                    case .waitingForConsent(let consent):
                        return waitForConsent(consent, action)
                    default:
                        return Just(action).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }
    }

    private func actionPublisher(_ data: Data) -> AnyPublisher<Action, Never> {
        switch data.action {
        case .link(let institution):
            return link(institution, data: data)
        case .deposit(let amountMinor, let product):
            return deposit(amountMinor: amountMinor, product: product, data: data)
        case .confirm(let order):
            return confirm(order: order, data: data)
        }
    }

    private func link(
        _ institution: OpenBanking.Institution,
        data: Data
    ) -> AnyPublisher<Action, Never> {
        banking.activate(bankAccount: data.account, with: institution.id)
            .flatMap { [banking] output -> AnyPublisher<Action, Never> in
                banking.poll(account: output, until: \.hasAuthorizationURL)
                    .flatMap { account -> AnyPublisher<OpenBanking.BankAccount, OpenBanking.Error> in
                        if let error = account.error {
                            return Fail(error: error).eraseToAnyPublisher()
                        } else {
                            return Just(account).setFailureType(to: OpenBanking.Error.self).eraseToAnyPublisher()
                        }
                    }
                    .map(Action.waitingForConsent(.linked(output, institution: institution)))
                    .catch(Action.failure)
                    .eraseToAnyPublisher()
            }
            .catch(Action.failure)
            .eraseToAnyPublisher()
    }

    private func deposit(amountMinor: String, product: String, data: Data) -> AnyPublisher<Action, Never> {
        banking.get(account: data.account)
            .flatMap { [banking] account -> AnyPublisher<OpenBanking.Payment, OpenBanking.Error> in
                banking.deposit(amountMinor: amountMinor, product: product, from: account)
            }
            .flatMap { [banking] payment in
                banking.poll(payment: payment)
                    .flatMap { payment -> AnyPublisher<OpenBanking.Payment.Details, OpenBanking.Error> in
                        if let error = payment.error {
                            return Fail(error: error).eraseToAnyPublisher()
                        } else {
                            return Just(payment).setFailureType(to: OpenBanking.Error.self).eraseToAnyPublisher()
                        }
                    }
                    .map((/Action.waitingForConsent).appending(path: /Output.deposited))
                    .catch(Action.failure)
            }
            .catch(Action.failure)
            .eraseToAnyPublisher()
    }

    private func confirm(order: OpenBanking.Order, data: Data) -> AnyPublisher<Action, Never> {

        func poll(_ order: OpenBanking.Order) -> AnyPublisher<Action, Never> {
            banking.poll(order: order)
                .flatMap { order -> AnyPublisher<OpenBanking.Order, OpenBanking.Error> in
                    if let error = order.paymentError {
                        return .failure(error)
                    } else {
                        return Just(order).setFailureType(to: OpenBanking.Error.self).eraseToAnyPublisher()
                    }
                }
                .map(Action.waitingForConsent(.confirmed(order)))
                .catch(Action.failure)
                .eraseToAnyPublisher()
        }

        return banking.get(order: order)
            .flatMap { [banking] order -> AnyPublisher<Action, Never> in
                if order.attributes?.authorisationUrl != nil {
                    return Just(.waitingForConsent(.confirmed(order)))
                        .eraseToAnyPublisher()
                } else {
                    return banking.confirm(order: order.id, using: order.paymentMethodId)
                        .flatMap(poll)
                        .catch(Action.failure)
                        .eraseToAnyPublisher()
                }
            }
            .catch(Action.failure)
            .eraseToAnyPublisher()
    }

    private lazy var consentErrorPublisher = banking.state.result(for: .consent.error, as: OpenBanking.Error.self)
        .publisher
        .mapError(OpenBanking.Error.init)
        .map(Action.failure)
        .catch(Action.failure)
        .eraseToAnyPublisher()

    private func waitForAccountLinking(
        account: OpenBanking.BankAccount,
        instiution: OpenBanking.Institution,
        action: Action
    ) -> AnyPublisher<Action, Never> {
        banking.state.publisher(for: .is.authorised, as: Bool.self)
            .ignoreResultFailure()
            .flatMap { [banking] authorised -> AnyPublisher<(Bool, OpenBanking.BankAccount), OpenBanking.Error> in
                banking.poll(account: account, until: \.isNotPending)
                    .map { (authorised, $0) }
                    .eraseToAnyPublisher()
            }
            .flatMap { [consentErrorPublisher] authorised, account -> AnyPublisher<Action, Never> in
                if authorised {
                    if let error = account.error {
                        return Just(Action.failure(error))
                            .eraseToAnyPublisher()
                    } else {
                        return Just(Action.success(.linked(account, institution: instiution)))
                            .eraseToAnyPublisher()
                    }
                } else {
                    return consentErrorPublisher
                }
            }
            .catch(Action.failure)
            .merge(with: Just(action))
            .eraseToAnyPublisher()
    }

    private func waitForConsent(output consent: Output, action: Action) -> AnyPublisher<Action, Never> {
        banking.state.publisher(for: .is.authorised, as: Bool.self)
            .ignoreResultFailure()
            .flatMap { [consentErrorPublisher] authorised -> AnyPublisher<Action, Never> in
                if authorised {
                    return Just(Action.success(consent))
                        .eraseToAnyPublisher()
                } else {
                    return consentErrorPublisher
                }
            }
            .catch(Action.failure)
            .merge(with: Just(action))
            .eraseToAnyPublisher()
    }
}

extension OpenBanking.BankAccount {

    var isNotPending: Bool {
        state != .pending
    }

    var hasAuthorizationURL: Bool {
        attributes.authorisationUrl != nil
    }
}
