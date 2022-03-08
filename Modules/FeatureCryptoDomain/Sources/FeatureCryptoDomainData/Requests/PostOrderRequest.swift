// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PostOrderRequest: Encodable {
    var domain: String?
    var records: [Record]?
    var isFree: Bool?
    var walletId: String?
    var owner: String?
}

struct Record: Encodable {
    var currency: String?
    var address: String?
}
