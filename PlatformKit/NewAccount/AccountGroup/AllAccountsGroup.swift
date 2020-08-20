//
//  AllAccountsGroup.swift
//  PlatformKit
//
//  Created by Paulo on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import RxSwift
import ToolKit

/// An `AccountGroup` containing all accounts.
final class AllAccountsGroup: AccountGroup {
    private typealias LocalizedString = LocalizationConstants.AccountGroup

    let accounts: [SingleAccount]
    let id: String = "AllAccountsGroup"
    let label: String = LocalizedString.allWallets
    let actions: AvailableActions = [.viewActivity]
    let isFunded: Bool = true

    var balance: Single<MoneyValue> {
        .error(AccountGroupError.noBalance)
    }

    init(accounts: [SingleAccount]) {
        self.accounts = accounts
    }
}
