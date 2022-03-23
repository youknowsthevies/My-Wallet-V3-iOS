// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public enum AccountType {
    /// An account controlled by BCDC
    case custodial
    /// An account controlled by the user within the BCDC ecosystem
    case nonCustodial
    /// An external account, such as an external crypto address
    case external
    /// An account representing a group of accounts
    case group
}

public protocol Account {

    /// A user-facing description for the account.
    var label: String { get }

    /// The `AccountType` of the account.
    var accountType: AccountType { get }

    /// The `CurrencyType` of the account
    var currencyType: CurrencyType { get }
}
