// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureCardIssuingDomain
import Foundation
import NabuNetworkError
import NetworkKit

public final class CardClient: CardClientAPI {

    // MARK: - Types

    private enum Path: String {
        case cards
        case sensitiveDetailsToken = "sensitive-details-token"
        case pinToken = "pin-token"
        case wallets
        case settings
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - API

    func orderCard(with parameters: OrderCardParameters) -> AnyPublisher<Card, NabuNetworkError> {
        let request = requestBuilder.post(
            path: [Path.cards.rawValue],
            body: try? parameters.encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: Card.self)
            .eraseToAnyPublisher()
    }

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [Card].self)
            .eraseToAnyPublisher()
    }

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, id],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: Card.self)
            .eraseToAnyPublisher()
    }

    func deleteCard(with id: String) -> AnyPublisher<Card, NabuNetworkError> {
        let request = requestBuilder.delete(
            path: [Path.cards.rawValue, id],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: Card.self)
            .eraseToAnyPublisher()
    }

    /// external token to be used in card plugin to retrieve PCI DSS scope card details, PAN, CVV
    func generateSensitiveDetailsToken(with cardId: String) -> AnyPublisher<String, NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, cardId, Path.sensitiveDetailsToken.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: String.self)
            .eraseToAnyPublisher()
    }

    /// one time token to be used in marqeta widget to reveal or update the card PIN
    func generatePinToken(with cardId: String) -> AnyPublisher<String, NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, cardId, Path.pinToken.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: String.self)
            .eraseToAnyPublisher()
    }

    func fetchLinkedWallets(with cardId: String) -> AnyPublisher<[Wallet], NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, cardId, Path.wallets.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [Wallet].self)
            .eraseToAnyPublisher()
    }

    /// array of linked wallets in priority order
    func updateWallets(with ids: [String], for cardId: String) -> AnyPublisher<[String], NabuNetworkError> {
        let request = requestBuilder.put(
            path: [Path.cards.rawValue, cardId, Path.wallets.rawValue],
            body: try? ids.encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [String].self)
            .eraseToAnyPublisher()
    }

    func fetchSettings(for cardId: String) -> AnyPublisher<CardSettings, NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, cardId, Path.settings.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: CardSettings.self)
            .eraseToAnyPublisher()
    }

    func update(settings: CardSettings, for cardId: String) -> AnyPublisher<CardSettings, NabuNetworkError> {
        let request = requestBuilder.put(
            path: [Path.cards.rawValue, cardId, Path.settings.rawValue],
            body: try? settings.encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: CardSettings.self)
            .eraseToAnyPublisher()
    }
}
