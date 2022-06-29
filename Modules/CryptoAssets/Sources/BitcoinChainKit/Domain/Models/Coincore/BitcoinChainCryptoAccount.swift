// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

public protocol BitcoinChainCryptoAccount: CryptoNonCustodialAccount {

    var coinType: BitcoinChainCoin { get }

    var hdAccountIndex: Int { get }

    var xPub: XPub { get }
}
