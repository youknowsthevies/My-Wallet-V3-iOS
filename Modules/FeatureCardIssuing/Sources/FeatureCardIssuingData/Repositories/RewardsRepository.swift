// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation

final class RewardsRepository: RewardsRepositoryAPI {

    private let client: RewardsClientAPI

    init(
        client: RewardsClientAPI
    ) {
        self.client = client
    }

    func fetchRewards() -> AnyPublisher<[Reward], NabuNetworkError> {
        client.fetchRewards()
    }

    /// returns linked reward ids to the card
    func fetchRewards(for card: Card) -> AnyPublisher<[String], NabuNetworkError> {
        client.fetchRewards(for: card.id)
    }

    func update(rewards: [Reward], for card: Card) -> AnyPublisher<[String], NabuNetworkError> {
        client.update(rewards: rewards.map(\.id), for: card.id)
    }
}
