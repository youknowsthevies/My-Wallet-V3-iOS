// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct SellOrder {
    let identifier: String
    let state: SwapActivityItemEvent.EventStatus
    let ccy: String?

    public init(
        identifier: String,
        state: SwapActivityItemEvent.EventStatus,
        ccy: String? = nil
    ) {
        self.identifier = identifier
        self.state = state
        self.ccy = ccy
    }
}
