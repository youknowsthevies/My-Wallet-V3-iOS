// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkError
import PlatformKit
import ToolKit

public protocol PaymentAccountsServiceAPI {

    /// Fetches the available payment methods for the current user and transforms them into `BlockchainAccount`s.
    /// - Parameters:
    ///   - currency: The target currency to buy using any of these payment methods. Currently unused.
    ///   - amount: The amount of currency to buy with any of these payment methods. Currently unused.
    func fetchPaymentMethodAccounts(
        for currency: CryptoCurrency,
        amount: MoneyValue
    ) -> AnyPublisher<[PaymentMethodAccount], NetworkError>
}

final class PaymentAccountsService: PaymentAccountsServiceAPI {

    let paymentMethodsService: PaymentMethodsServiceAPI
    let linkedBanksService: LinkedBanksFactoryAPI
    let linkedCardsService: CardListServiceAPI

    init(
        paymentMethodsService: PaymentMethodsServiceAPI = resolve(),
        linkedBanksService: LinkedBanksFactoryAPI = resolve(),
        linkedCardsService: CardListServiceAPI = resolve()
    ) {
        self.paymentMethodsService = paymentMethodsService
        self.linkedBanksService = linkedBanksService
        self.linkedCardsService = linkedCardsService
    }

    func fetchPaymentMethodAccounts(
        for currency: CryptoCurrency,
        amount: MoneyValue
    ) -> AnyPublisher<[PaymentMethodAccount], NetworkError> {
        let linkedBanksService = self.linkedBanksService
        let linkedCardsService = self.linkedCardsService
        // NOTE: currency and amount are ignored until new API is ready to use
        return paymentMethodsService.paymentMethods
            .asPublisher()
            .flatMap { paymentMethods -> AnyPublisher<[PaymentMethodAccount], Error> in
                let linkablePaymentMethods = paymentMethods.map { paymentMethod in
                    PaymentMethodAccount(
                        paymentMethod: paymentMethod,
                        linkedAccount: nil
                    )
                }

                let linkedCardAccounts = linkedCardsService
                    .cards
                    .asPublisher()
                    .mapToCreditCardAccounts()
                    .filter(canPerform: .buy)
                    .mapToPaymentAccounts(
                        paymentMethods: paymentMethods,
                        filter: { $0.type.isCard }
                    )

                let linkedBankAccounts = linkedBanksService
                    .nonWireTransferBanks // NOTE: LinkedBankAccounts don't have any supported actions, so use this.
                    .asPublisher()
                    .mapToPaymentAccounts(
                        paymentMethods: paymentMethods,
                        filter: { $0.type.isBankAccount }
                    )

                let linkablePaymentAccounts = Just(linkablePaymentMethods)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()

                return Publishers.Zip3(
                    linkedCardAccounts,
                    linkedBankAccounts,
                    linkablePaymentAccounts
                )
                .map { cards, bankAccounts, paymentMethods in
                    let allLinkedAccounts = cards + bankAccounts
                    return allLinkedAccounts.isEmpty ? paymentMethods : allLinkedAccounts
                }
                .eraseToAnyPublisher()
            }
            .mapError { error in
                guard let networkError = error as? NetworkError else {
                    return NetworkError.authentication(error)
                }
                return networkError
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output: Collection, Output.Element: FiatAccount {

    /// Maps `FiatAccount`s to `PaymentMethodAccount`s
    /// - Parameters:
    ///   - paymentMethods: A list of available payment methods to be used for the mapping.
    ///   - filter: An extra filter for the payment method - for example, `isCard` or `isBank`. The list of accounts is filtered by currency and other parameters on the payment method.
    /// - Returns:A `Combine.Publisher` outputting a list of `PaymentMethodAccount`s.
    func mapToPaymentAccounts(
        paymentMethods: [PaymentMethod],
        filter: @escaping (PaymentMethod) -> Bool
    ) -> AnyPublisher<[FeatureTransactionDomain.PaymentMethodAccount], Failure> {
        map { accounts in
            accounts.compactMap { account in
                let paymentMethod = paymentMethods.first { paymentMethod in
                    paymentMethod.isVisible
                        && paymentMethod.fiatCurrency == account.fiatCurrency
                        && filter(paymentMethod)
                }
                guard let filteredPaymentMethod = paymentMethod else {
                    return nil
                }
                return PaymentMethodAccount(
                    paymentMethod: filteredPaymentMethod,
                    linkedAccount: account
                )
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output: Collection, Output.Element == CardData {

    func mapToCreditCardAccounts() -> AnyPublisher<[FeatureTransactionDomain.CreditCardAccount], Failure> {
        map {
            $0.map(CreditCardAccount.init(cardData:))
        }
        .eraseToAnyPublisher()
    }
}
