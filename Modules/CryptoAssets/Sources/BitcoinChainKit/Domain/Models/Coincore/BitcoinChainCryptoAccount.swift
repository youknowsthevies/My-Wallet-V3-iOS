// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

public protocol BitcoinChainCryptoAccount: CryptoNonCustodialAccount {
    var hdAccountIndex: Int { get }
}
