//
//  AllAccountsGroup.swift
//  PlatformKit
//
//  Created by Paulo on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

/// An `AccountGroup` cointaining all accounts.
final class AllAccountsGroup: AccountGroup {

    let actions: AvailableActions = [.viewActivity]

    let accounts: [SingleAccount]

    let id: String = "AllWalletsAccount"

    let label: String = "All Wallets"

    var balance: Single<MoneyValue> {
        .error(AccountGroupError.noBalance)
    }

    let isFunded: Bool = true

    init(accounts: [SingleAccount]) {
        self.accounts = accounts
    }
}
