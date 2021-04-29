// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct ERC20AssetAccountDetails: AssetAccountDetails, Equatable {
    public typealias Account = ERC20AssetAccount

    public var account: Account
    public var balance: CryptoValue
}
