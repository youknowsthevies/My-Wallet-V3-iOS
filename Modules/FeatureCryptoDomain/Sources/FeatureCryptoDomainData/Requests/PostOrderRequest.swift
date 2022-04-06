// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCryptoDomainDomain
import Foundation

public struct PostOrderRequest: Encodable {
    var domainCampaign: String
    var domain: String
    var owner: String
    var records: [Record]
    var isFree: Bool
}

struct Record: Encodable {
    var currency: String
    var address: String?
}

extension Record {
    init(from resolutionRecord: ResolutionRecord) {
        self.init(
            currency: resolutionRecord.symbol,
            address: resolutionRecord.walletAddress
        )
    }
}
