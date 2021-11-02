// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

public protocol OpenBankingClientProtocol {

    func createBankAccount() -> AnyPublisher<OpenBanking.BankAccount, OpenBanking.Error>

    func activate(
        bankAccount: OpenBanking.BankAccount,
        with institution: Identity<OpenBanking.Institution>
    ) -> AnyPublisher<OpenBanking.BankAccount, OpenBanking.Error>

    func confirm(
        order: Identity<OpenBanking.Order>,
        using paymentMethod: String
    ) -> AnyPublisher<OpenBanking.Order, OpenBanking.Error>

    func deposit(
        amountMinor: String,
        product: String,
        from account: OpenBanking.BankAccount
    ) -> AnyPublisher<OpenBanking.Payment, OpenBanking.Error>

    func get(
        account: OpenBanking.BankAccount
    ) -> AnyPublisher<OpenBanking.BankAccount, OpenBanking.Error>

    func poll(
        account: OpenBanking.BankAccount
    ) -> AnyPublisher<OpenBanking.BankAccount, OpenBanking.Error>

    func get(
        payment: OpenBanking.Payment
    ) -> AnyPublisher<OpenBanking.Payment.Details, OpenBanking.Error>

    func poll(
        payment: OpenBanking.Payment
    ) -> AnyPublisher<OpenBanking.Payment.Details, OpenBanking.Error>

    func get(
        order: OpenBanking.Order
    ) -> AnyPublisher<OpenBanking.Order, OpenBanking.Error>

    func poll(
        order: OpenBanking.Order
    ) -> AnyPublisher<OpenBanking.Order, OpenBanking.Error>
}
