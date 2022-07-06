// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureReferralDomain

public struct ReferralRepository: ReferralRepositoryAPI {
    private let client: ReferralClientAPI

    public init(client: ReferralClientAPI) {
        self.client = client
    }

    public func fetchReferralCampaign(for currency: String) -> AnyPublisher<Referral, NetworkError> {
        client
            .fetchReferralCampaign(for: currency)
            .map { $0.toReferral() }
            .eraseToAnyPublisher()
    }

    public func createReferral(with code: String) -> AnyPublisher<Void, NetworkError> {
        client
            .createReferral(with: code)
            .eraseToAnyPublisher()
    }
}

extension ReferralResponse {
    func toReferral() -> Referral {
        let steps = criteria
            .map { Step(text: $0) }

        return Referral(
            code: code,
            rewardTitle: rewardTitle,
            rewardSubtitle: rewardSubtitle,
            steps: steps
        )
    }
}
