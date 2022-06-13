// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureReferralDomain
import FeatureSettingsDomain
import Foundation
import ToolKit

final class ReferralsAdapter: ReferralAdapterAPI {
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let referralService: ReferralServiceAPI

    init(
        featureFlagsService: FeatureFlagsServiceAPI,
        referralService: ReferralServiceAPI
    ) {
        self.featureFlagsService = featureFlagsService
        self.referralService = referralService
    }

    func hasReferral() -> AnyPublisher<Referral?, Never> {
        Publishers
            .CombineLatest(
                featureFlagsService.isEnabled(.referral),
                referralService
                    .fetchReferralCampaign()
            )
            .map { isEnabled, referral in
                isEnabled ? referral : nil
            }
            .eraseToAnyPublisher()
    }
}
