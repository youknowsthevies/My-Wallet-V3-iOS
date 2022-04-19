// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCryptoDomainDomain
import Foundation

public struct PostOrderRequest: Encodable {
    let domainCampaign: String
    let domain: String
    let owner: String
    let records: [Record]
    let isFree: Bool
}

struct Record: Encodable {
    let currency: String
    let address: String?
}

extension Record {
    init(from resolutionRecord: ResolutionRecord) {
        self.init(
            currency: resolutionRecord.symbol,
            address: resolutionRecord.walletAddress
        )
    }
}
