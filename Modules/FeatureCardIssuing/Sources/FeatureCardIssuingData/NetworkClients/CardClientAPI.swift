// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCardIssuingDomain
import Foundation
import NabuNetworkError

protocol CardClientAPI {

    func orderCard(with parameters: OrderCardParameters) -> AnyPublisher<[Card], NabuNetworkError>

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError>

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError>

    func deleteCard(with id: String) -> AnyPublisher<Card, NabuNetworkError>

    /// external token to be used in card plugin to retrieve PCI DSS scope card details, PAN, CVV
    func generateSensitiveDetailsToken(with cardId: String) -> AnyPublisher<String, NabuNetworkError>

    /// one time token to be used in marqeta widget to reveal or update the card PIN
    func generatePinToken(with cardId: String) -> AnyPublisher<String, NabuNetworkError>

    func fetchLinkedWallets(with cardId: String) -> AnyPublisher<[Wallet], NabuNetworkError>

    /// array of linked wallets in priority order
    func updateWallets(with ids: [String], for cardId: String) -> AnyPublisher<[String], NabuNetworkError>

    func fetchSettings(for cardId: String) -> AnyPublisher<CardSettings, NabuNetworkError>

    func update(settings: CardSettings, for cardId: String) -> AnyPublisher<CardSettings, NabuNetworkError>
}

struct OrderCardParameters: Encodable {
    let productCode: String
    let deliveryAddress: Card.Address
}
