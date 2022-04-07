// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct ClaimEligibilityResponse: Decodable {
    var domainCampaignName: String
    var isEligible: Bool
}
