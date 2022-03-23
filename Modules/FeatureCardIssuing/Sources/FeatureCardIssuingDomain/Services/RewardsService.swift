// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NabuNetworkError

final class RewardsService: RewardsServiceAPI {

    private let repository: RewardsRepositoryAPI

    init(
        repository: RewardsRepositoryAPI
    ) {
        self.repository = repository
    }

    func fetchRewards() -> AnyPublisher<[Reward], NabuNetworkError> {
        repository.fetchRewards()
    }

    func fetchRewards(for card: Card) -> AnyPublisher<[String], NabuNetworkError> {
        repository.fetchRewards(for: card)
    }

    func update(rewards: [Reward], for card: Card) -> AnyPublisher<[String], NabuNetworkError> {
        repository.update(rewards: rewards, for: card)
    }
}
