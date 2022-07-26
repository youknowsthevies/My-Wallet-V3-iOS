// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Foundation

struct BchSigningInput {
    let spendableOutputs: [UnspentOutput]
    let amount: UInt64
    let change: UInt64
    let privateKeys: [Data]
    let toAddress: String
    let changeAddress: String
    let dust: DustMixing?
}
