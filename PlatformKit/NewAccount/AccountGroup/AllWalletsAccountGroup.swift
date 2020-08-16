//
//  AllWalletsAccountGroup.swift
//  PlatformKit
//
//  Created by Paulo on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

/// An `AccountGroup` cointaining all accounts.
final class AllAccountsGroup: AccountGroup {

    enum AllAccountsGroupError: Error {
        case noBalance

        var localizedDescription: String {
            switch self {
            case .noBalance:
                return "No unified balance for All Wallets meta account"
            }
        }
    }

    let actions: AvailableActions = [.viewActivity]

    let accounts: [SingleAccount]

    let id: String = "AllWalletsAccount"

    let label: String = "All Wallets"

    var balance: Single<MoneyValue> {
        .error(AllAccountsGroupError.noBalance)
    }

    let isFunded: Bool = true

    init(accounts: [SingleAccount]) {
        self.accounts = accounts
    }
}
