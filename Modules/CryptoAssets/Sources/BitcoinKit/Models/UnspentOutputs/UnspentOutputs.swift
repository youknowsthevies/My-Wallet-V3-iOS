// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BitcoinChainKit
import PlatformKit

struct UnspentOutputs: Equatable {

    let outputs: [UnspentOutput]
}

extension UnspentOutputs {
    init(networkResponse: UnspentOutputsResponse) {
        outputs = networkResponse
            .unspent_outputs
            .map { UnspentOutput(response: $0) }
    }
}
