// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct PushTxRequest: Encodable {
    let rawTx: String
    let network: String
    let api_code: String
}
