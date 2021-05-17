// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

struct SwapOrder {
    let identifier: String
    let state: SwapActivityItemEvent.EventStatus
    let depositAddress: String?

    init(identifier: String,
         state: SwapActivityItemEvent.EventStatus,
         depositAddress: String? = nil) {
        self.identifier = identifier
        self.state = state
        self.depositAddress = depositAddress
    }
}
