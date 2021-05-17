// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol AssetAccountDetails {
    associatedtype Account: AssetAccount

    // Decorated account
    var account: Account { get }
    var balance: CryptoValue { get }
}
