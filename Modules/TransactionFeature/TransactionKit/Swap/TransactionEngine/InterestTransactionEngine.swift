// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

public protocol InterestTransactionEngine: TransactionEngine {
    var minimumDepositLimits: Single<FiatValue> { get }
}
