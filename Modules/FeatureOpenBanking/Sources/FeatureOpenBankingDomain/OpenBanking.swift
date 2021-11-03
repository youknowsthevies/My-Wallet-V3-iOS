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
        case launchAuthorisation(URL)
        case waitingForConsent(Output)
        case success(Output)
        case failure(OpenBanking.Error)
    }

    public private(set) var banking: OpenBankingClientProtocol

    public var state: State { banking.state }
    private var scheduler: AnySchedulerOf<DispatchQueue> { banking.scheduler }

    public init(banking: OpenBankingClientProtocol) {
        self.banking = banking
    }

    public func createBankAccount() -> AnyPublisher<OpenBanking.BankAccount, Error> {
        banking.createBankAccount()
    }

    public func start(_ data: Data) -> AnyPublisher<Action, Never> {
        let poll: AnyPublisher<Action, Never>
        switch data.action {
        case .link(let institution):
            poll = banking.activate(bankAccount: data.account, with: institution.id)
                .flatMap { [state, banking] output in
                    banking.poll(account: output)
                        .flatMap { account -> AnyPublisher<OpenBanking.BankAccount, OpenBanking.Error> in
                            if let error = account.error {
                                return Fail(error: error).eraseToAnyPublisher()
                            } else {
                                return Just(account).setFailureType(to: OpenBanking.Error.self).eraseToAnyPublisher()
                            }
                        }
                        .mapped(to: Action.waitingForConsent(.linked(output, institution: institution)))
                        .catch(Action.failure)
                        .merge(
                            with: state.publisher(for: .authorisation.url, as: URL.self)
                                .ignoreResultFailure()
                                .mapped(to: Action.launchAuthorisation)
                                .eraseToAnyPublisher()
                        )
                }
                .catch(Action.failure)
                .eraseToAnyPublisher()
        case .deposit(let amountMinor, let product):
            poll = banking.get(account: data.account)
                .flatMap { [banking] account in
                    banking.deposit(amountMinor: amountMinor, product: product, from: account)
                }
                .flatMap { [state, banking] payment in
                    banking.poll(payment: payment)
                        .flatMap { payment -> AnyPublisher<OpenBanking.Payment.Details, OpenBanking.Error> in
                            if let error = payment.extraAttributes?.error {
                                return Fail(error: error).eraseToAnyPublisher()
                            } else {
                                return Just(payment).setFailureType(to: OpenBanking.Error.self).eraseToAnyPublisher()
                            }
                        }
                        .mapped(to: (/Action.waitingForConsent).appending(path: /Output.deposited))
                        .catch(Action.failure)
                        .merge(
                            with: state.publisher(for: .authorisation.url, as: URL.self)
                                .ignoreResultFailure()
                                .mapped(to: Action.launchAuthorisation)
                                .eraseToAnyPublisher()
                        )
                }
                .catch(Action.failure)
                .eraseToAnyPublisher()
        case .confirm(let order):
            poll = banking.confirm(order: order.id, using: order.paymentMethodId)
                .flatMap { [state, banking] order in
                    banking.poll(order: order)
                        .mapped(to: Action.waitingForConsent(.confirmed(order)))
                        .catch(Action.failure)
                        .merge(
                            with: state.publisher(for: .authorisation.url, as: URL.self)
                                .ignoreResultFailure()
                                .mapped(to: Action.launchAuthorisation)
                                .eraseToAnyPublisher()
                        )
                }
                .catch(Action.failure)
                .eraseToAnyPublisher()
        }

        return [
            poll,
            poll
                .filter(/Action.waitingForConsent)
                .flatMap { [state] consent in
                    state.publisher(for: .is.authorised, as: Bool.self)
                        .ignoreResultFailure()
                        .flatMap { authorised -> AnyPublisher<Action, Never> in
                            if authorised {
                                return Just(Action.success(consent))
                                    .eraseToAnyPublisher()
                            } else {
                                return state.result(for: .consent.error, as: OpenBanking.Error.self)
                                    .publisher
                                    .mapError(OpenBanking.Error.init)
                                    .mapped(to: Action.failure)
                                    .catch(Action.failure)
                                    .eraseToAnyPublisher()
                            }
                        }
                }
                .eraseToAnyPublisher()
        ]
        .merge()
        .eraseToAnyPublisher()
    }
}
