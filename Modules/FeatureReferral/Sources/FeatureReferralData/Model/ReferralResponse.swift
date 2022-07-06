// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct ReferralResponse: Decodable {
    public var code: String
    public var rewardTitle: String
    public var rewardSubtitle: String
    public var criteria: [String]
}
