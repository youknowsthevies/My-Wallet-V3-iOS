// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NabuNetworkError

public protocol CardRepositoryAPI {

    func orderCard(product: Product, at address: Card.Address) -> AnyPublisher<[Card], NabuNetworkError>

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError>

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError>

    func delete(card: Card) -> AnyPublisher<Card, NabuNetworkError>

    /// external token to be used in card plugin to retrieve PCI DSS scope card details, PAN, CVV
    func generateSensitiveDetailsToken(for card: Card) -> AnyPublisher<String, NabuNetworkError>

    /// one time token to be used in marqeta widget to reveal or update the card PIN
    func generatePinToken(for card: Card) -> AnyPublisher<String, NabuNetworkError>

    func fetchLinkedWallets(for card: Card) -> AnyPublisher<[Wallet], NabuNetworkError>

    /// array of linked wallets in priority order
    func update(wallets: [Wallet], for card: Card) -> AnyPublisher<[String], NabuNetworkError>

    func fetchSettings(for card: Card) -> AnyPublisher<CardSettings, NabuNetworkError>

    func update(settings: CardSettings, for card: Card) -> AnyPublisher<CardSettings, NabuNetworkError>
}
