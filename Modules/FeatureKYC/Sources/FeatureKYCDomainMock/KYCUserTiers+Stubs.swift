// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureKYCDomain
import PlatformKit

extension KYC.UserTiers {

    public static var tier0: KYC.UserTiers {
        KYC.UserTiers(
            tiers: [
                .init(tier: .tier1, state: .none),
                .init(tier: .tier2, state: .none)
            ]
        )
    }

    public static var tier1Approved: KYC.UserTiers {
        KYC.UserTiers(
            tiers: [
                .init(tier: .tier1, state: .verified),
                .init(tier: .tier2, state: .none)
            ]
        )
    }

    public static var tier2Approved: KYC.UserTiers {
        KYC.UserTiers(
            tiers: [
                .init(tier: .tier1, state: .verified),
                .init(tier: .tier2, state: .verified)
            ]
        )
    }
}
