// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

/// An ERC-20 token account.
public struct ERC20TokenAccount: Equatable {

    /// The balance of the account.
    public let balance: CryptoValue

    /// The `CryptoCurrency` of the ERC-20 token.
    public var currency: CryptoCurrency {
        balance.currency
    }

    /// Creates an ERC-20 token account.
    ///
    /// - Parameters:
    ///   - balance:     An ERC-20 balance.
    public init(balance: CryptoValue) {
        self.balance = balance
    }
}

/// A dictionary of ERC-20 token accounts, indexed by ERC-20 crypto currencies.
public typealias ERC20TokenAccounts = [CryptoCurrency: ERC20TokenAccount]
