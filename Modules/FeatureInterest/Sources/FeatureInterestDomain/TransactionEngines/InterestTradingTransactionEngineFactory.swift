// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import ToolKit

/// Transaction Engine Factory for Interest Deposit or Withdraw from/to a Trading Account.
final class InterestTradingTransactionEngineFactory: InterestTradingTransactionEngineFactoryAPI {
    func build(
        requiresSecondPassword: Bool,
        action: AssetAction
    ) -> InterestTransactionEngine {
        switch action {
        case .interestTransfer:
            return InterestDepositTradingTransactionEngine(
                requireSecondPassword: requiresSecondPassword
            )
        case .interestWithdraw:
            return InterestWithdrawTradingTransactionEngine(
                requireSecondPassword: requiresSecondPassword
            )
        default:
            unimplemented()
        }
    }
}
