// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NabuNetworkError

final class CardService: CardServiceAPI {

    private let repository: CardRepositoryAPI

    init(
        repository: CardRepositoryAPI
    ) {
        self.repository = repository
    }

    func orderCard(
        product: Product,
        at address: Card.Address,
        with ssn: String
    ) -> AnyPublisher<Card, NabuNetworkError> {
        repository.orderCard(product: product, at: address, with: ssn)
    }

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError> {
        repository.fetchCards()
    }

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError> {
        repository.fetchCard(with: id)
    }

    func delete(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        repository.delete(card: card)
    }

    func generateSensitiveDetailsToken(for card: Card) -> AnyPublisher<String, NabuNetworkError> {
        repository.generateSensitiveDetailsToken(for: card)
    }

    func generatePinToken(for card: Card) -> AnyPublisher<String, NabuNetworkError> {
        repository.generatePinToken(for: card)
    }

    func fetchLinkedWallets(for card: Card) -> AnyPublisher<[Wallet], NabuNetworkError> {
        repository.fetchLinkedWallets(for: card)
    }

    func update(wallets: [Wallet], for card: Card) -> AnyPublisher<[String], NabuNetworkError> {
        repository.update(wallets: wallets, for: card)
    }

    func fetchSettings(for card: Card) -> AnyPublisher<CardSettings, NabuNetworkError> {
        repository.fetchSettings(for: card)
    }

    func update(settings: CardSettings, for card: Card) -> AnyPublisher<CardSettings, NabuNetworkError> {
        repository.update(settings: settings, for: card)
    }
}
