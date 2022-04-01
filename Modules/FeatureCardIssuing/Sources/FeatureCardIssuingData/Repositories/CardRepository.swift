// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCardIssuingDomain
import Foundation
import NabuNetworkError

final class CardRepository: CardRepositoryAPI {

    private let client: CardClientAPI

    init(
        client: CardClientAPI
    ) {
        self.client = client
    }

    func orderCard(product: Product, at address: Card.Address, with ssn: String) -> AnyPublisher<Card, NabuNetworkError> {
        client.orderCard(with: .init(productCode: product.productCode, deliveryAddress: address, ssn: ssn))
    }

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError> {
        client.fetchCards()
    }

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError> {
        client.fetchCard(with: id)
    }

    func delete(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        client.deleteCard(with: card.cardId)
    }

    func generateSensitiveDetailsToken(for card: Card) -> AnyPublisher<String, NabuNetworkError> {
        client.generateSensitiveDetailsToken(with: card.cardId)
    }

    func generatePinToken(for card: Card) -> AnyPublisher<String, NabuNetworkError> {
        client.generatePinToken(with: card.cardId)
    }

    func fetchLinkedWallets(for card: Card) -> AnyPublisher<[Wallet], NabuNetworkError> {
        client.fetchLinkedWallets(with: card.cardId)
    }

    func update(wallets: [Wallet], for card: Card) -> AnyPublisher<[String], NabuNetworkError> {
        client.updateWallets(with: wallets.map(\.walletId), for: card.cardId)
    }

    func fetchSettings(for card: Card) -> AnyPublisher<CardSettings, NabuNetworkError> {
        client.fetchSettings(for: card.cardId)
    }

    func update(settings: CardSettings, for card: Card) -> AnyPublisher<CardSettings, NabuNetworkError> {
        client.update(settings: settings, for: card.cardId)
    }
}
