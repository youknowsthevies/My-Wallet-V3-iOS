// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureCardIssuingDomain
import Foundation
import NabuNetworkError
import NetworkKit

public final class RewardsClient: RewardsClientAPI {

    // MARK: - Types

    private enum Path: String {
        case cards
        case rewards
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

    func fetchRewards() -> AnyPublisher<[Reward], NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.rewards.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [Reward].self)
            .eraseToAnyPublisher()
    }

    /// returns linked reward ids to the card
    func fetchRewards(for cardId: String) -> AnyPublisher<[String], NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, cardId, Path.rewards.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [String].self)
            .eraseToAnyPublisher()
    }

    func update(rewards: [String], for cardId: String) -> AnyPublisher<[String], NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, cardId, Path.rewards.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [String].self)
            .eraseToAnyPublisher()
    }
}
