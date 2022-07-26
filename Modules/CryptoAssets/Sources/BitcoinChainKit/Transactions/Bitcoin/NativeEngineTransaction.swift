// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Foundation

struct NativeEngineTransaction: EngineTransaction {

    var encodedMsg: String

    var msgSize: Int

    var txHash: String
}
