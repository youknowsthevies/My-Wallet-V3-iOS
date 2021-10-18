// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public protocol InterestTradingTransactionEngineFactoryAPI {
    func build(
        requiresSecondPassword: Bool,
        action: AssetAction
    ) -> InterestTransactionEngine
}
