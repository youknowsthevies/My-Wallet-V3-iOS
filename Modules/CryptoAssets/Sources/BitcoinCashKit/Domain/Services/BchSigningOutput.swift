// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct BchSigningOutput {
    let data: Data
    let transactionHash: String
    let replayProtectionLockSecret: String?
}
