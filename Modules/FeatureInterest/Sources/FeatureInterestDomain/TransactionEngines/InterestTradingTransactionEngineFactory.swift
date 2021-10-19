// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import ToolKit

final class InterestTradingTransactionEngineFactory: InterestTradingTransactionEngineFactoryAPI {
    func build(
        requiresSecondPassword: Bool,
        action: AssetAction
    ) -> InterestTransactionEngine {
        switch action {
        case .interestTransfer:
            return InterestDepositTradingTransationEngine(
                requireSecondPassword: requiresSecondPassword
            )
        case .interestWithdraw:
            return InterestWithdrawTradingTransationEngine(
                requireSecondPassword: requiresSecondPassword
            )
        default:
            unimplemented()
        }
    }
}
