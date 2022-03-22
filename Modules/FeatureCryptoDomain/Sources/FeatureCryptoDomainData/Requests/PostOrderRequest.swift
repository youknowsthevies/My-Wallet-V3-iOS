// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCryptoDomainDomain
import Foundation

public struct PostOrderRequest: Encodable {
    var domain: String?
    var records: [Record]?
    var isFree: Bool?
    // TODO: rename walletId to nabuUserId when backend changes are ready
    var walletId: String?
    var owner: String?
}

struct Record: Encodable {
    var currency: String?
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
