// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation

protocol CardClientAPI {

    func orderCard(with parameters: OrderCardParameters) -> AnyPublisher<Card, NabuNetworkError>

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError>

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError>

    func deleteCard(with id: String) -> AnyPublisher<Card, NabuNetworkError>

    /// external token to be used in card plugin to retrieve PCI DSS scope card details, PAN, CVV
    func generateSensitiveDetailsToken(with cardId: String) -> AnyPublisher<String, NabuNetworkError>

    /// one time token to be used in marqeta widget to reveal or update the card PIN
    func generatePinToken(with cardId: String) -> AnyPublisher<String, NabuNetworkError>

    func fetchLinkedAccount(with cardId: String) -> AnyPublisher<AccountCurrency, NabuNetworkError>

    func updateAccount(
        with params: AccountCurrency,
        for cardId: String
    ) -> AnyPublisher<AccountCurrency, NabuNetworkError>

    func eligibleAccounts(for cardId: String) -> AnyPublisher<[AccountBalance], NabuNetworkError>

    func lock(cardId: String) -> AnyPublisher<Card, NabuNetworkError>

    func unlock(cardId: String) -> AnyPublisher<Card, NabuNetworkError>
}

struct OrderCardParameters: Encodable {
    let productCode: String
    let deliveryAddress: Card.Address
    let ssn: String
}
