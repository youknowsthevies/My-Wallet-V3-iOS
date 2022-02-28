// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct OrderDomainRequest {

    struct ResolutionRecord {
        let currency: String
        let address: String
    }
    
    let isFree: Bool
    let domain: String
    let owner: String
    let walletId: String
    let records: [ResolutionRecord]
}
