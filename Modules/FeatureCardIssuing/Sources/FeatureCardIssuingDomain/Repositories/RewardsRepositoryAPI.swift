// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol RewardsRepositoryAPI {

    func fetchRewards() -> AnyPublisher<[Reward], NabuNetworkError>

    /// returns linked reward ids to the card
    func fetchRewards(for card: Card) -> AnyPublisher<[String], NabuNetworkError>

    func update(rewards: [Reward], for card: Card) -> AnyPublisher<[String], NabuNetworkError>
}
