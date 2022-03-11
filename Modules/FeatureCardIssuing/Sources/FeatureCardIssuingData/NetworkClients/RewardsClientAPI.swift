// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCardIssuingDomain
import Foundation
import NabuNetworkError

protocol RewardsClientAPI {

    func fetchRewards() -> AnyPublisher<[Reward], NabuNetworkError>

    /// returns linked reward ids to the card
    func fetchRewards(for cardId: String) -> AnyPublisher<[String], NabuNetworkError>

    func update(rewards: [String], for cardId: String) -> AnyPublisher<[String], NabuNetworkError>
}
