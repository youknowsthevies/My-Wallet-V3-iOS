// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

final class PendingTransctionStateProviderFactory {
    static func pendingTransactionStateProvider(action: AssetAction) -> PendingTransactionStateProviding {
        switch action {
        case .withdraw:
            return WithdrawPendingTransactionStateProvider()
        case .deposit:
            return DepositPendingTransactionStateProvider()
        case .send:
            return SendPendingTransactionStateProvider()
        case .swap:
            return SwapPendingTransactionStateProvider()
        default:
            unimplemented()
        }
    }
}
