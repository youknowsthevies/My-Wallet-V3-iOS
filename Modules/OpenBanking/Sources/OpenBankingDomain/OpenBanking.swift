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

    public struct Action: Hashable {

        public init(account: OpenBanking.BankAccount, then: OpenBanking.Action.Then) {
            self.account = account
            self.then = then
        }

        public enum Then: Hashable {
            case link(institution: OpenBanking.Institution)
            case deposit(amountMinor: String, product: String)
            case confirm(order: OpenBanking.Order)
        }

        public let account: OpenBanking.BankAccount
        public let then: Then
    }

    public enum Polling: Hashable {
        case link(account: OpenBanking.BankAccount)
        case deposit(payment: OpenBanking.Payment)
        case confirm(order: OpenBanking.Order)
    }

    public enum Success: Hashable {
        case link
        case deposit(OpenBanking.Payment.Details)
        case confirm
    }

    public enum Effect: FailureAction, Hashable {
        case launchAuthorisation(URL)
        case success(Success)
        case failure(OpenBanking.Error)
    }

    public private(set) var banking: OpenBankingClientProtocol
    public var state: State

    private var app: URLOpener
    private var scheduler: AnySchedulerOf<DispatchQueue>

    public convenience init(
        state: Session.State<OpenBanking.Key>,
        banking: OpenBankingClientProtocol,
        scheduler: DispatchQueue = .main,
        app: URLOpener = resolve()
    ) {
        self.init(
            state: state,
            banking: banking,
            scheduler: scheduler.eraseToAnyScheduler(),
            app: app
        )
    }

    public init(
        state: Session.State<OpenBanking.Key>,
        banking: OpenBankingClientProtocol,
        scheduler: AnySchedulerOf<DispatchQueue>,
        app: URLOpener = resolve()
    ) {

        self.state = state
        self.banking = banking
        self.scheduler = scheduler
        self.app = app
    }

    public func createBankAccount() -> AnyPublisher<OpenBanking.BankAccount, Error> {
        banking.createBankAccount()
    }

    public func start(action: Action) -> AnyPublisher<Effect, Never> {
        switch action.then {
        case .link(let institution):
            return banking.activate(bankAccount: action.account, with: institution.id)
                .flatMap { [banking] output in
                    banking.poll(account: output)
                        .flatMap { account -> AnyPublisher<OpenBanking.BankAccount, OpenBanking.Error> in
                            if let error = account.error {
                                return Fail(error: error).eraseToAnyPublisher()
                            } else {
                                return Just(account).setFailureType(to: OpenBanking.Error.self).eraseToAnyPublisher()
                            }
                        }
                        .mapped(to: Effect.success(.link))
                        .catch(Effect.failure)
                        .eraseToAnyPublisher()
                }
                .catch(Effect.failure)
                .eraseToAnyPublisher()
        case .deposit(let amountMinor, let product):
            return banking.get(account: action.account)
                .flatMap { [banking] account in
                    banking.deposit(amountMinor: amountMinor, product: product, from: account)
                }
                .flatMap { [banking] payment in
                    banking.poll(payment: payment)
                        .flatMap { payment -> AnyPublisher<OpenBanking.Payment.Details, OpenBanking.Error> in
                            if let error = payment.extraAttributes?.error {
                                return Fail(error: error).eraseToAnyPublisher()
                            } else {
                                return Just(payment).setFailureType(to: OpenBanking.Error.self).eraseToAnyPublisher()
                            }
                        }
                        .mapped(to: (/Effect.success).appending(path: /Success.deposit))
                        .catch(Effect.failure)
                }
                .catch(Effect.failure)
                .eraseToAnyPublisher()
        case .confirm(let order):
            return banking.confirm(order: order.id, using: order.paymentMethodId)
                .flatMap { [banking] order in
                    banking.poll(order: order)
                        .mapped(to: Effect.success(.confirm))
                        .catch(Effect.failure)
                }
                .catch(Effect.failure)
                .eraseToAnyPublisher()
        }
    }
}

extension Publisher where Output: ResultProtocol {

    public func mapped<T>(
        to action: @escaping (Output.Success) -> T
    ) -> Publishers.Map<Self, T> where T: FailureAction {
        map { it -> T in
            switch it.result {
            case .success(let value):
                return action(value)
            case .failure(let error):
                return T.failure(error)
            }
        }
    }

    public func mapped<T>(
        to action: CasePath<T, Output.Success>
    ) -> Publishers.Map<Self, T> where T: FailureAction {
        map { it -> T in
            switch it.result {
            case .success(let value):
                return action.embed(value)
            case .failure(let error):
                return T.failure(error)
            }
        }
    }
}
