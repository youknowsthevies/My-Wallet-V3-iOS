//
//  FiatAccountGroup.swift
//  PlatformKit
//
//  Created by Paulo on 19/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import Localization

/// An `AccountGroup` containing only fiat accounts.
public class FiatAccountGroup: AccountGroup {
    private typealias LocalizedString = LocalizationConstants.AccountGroup

    public let id: String = "FiatAccountGroup"

    public let label: String

    public let accounts: [SingleAccount]

    public var balance: Single<MoneyValue> {
        .error(AccountGroupError.noBalance)
    }

    public init(accounts: [SingleAccount]) {
        self.label = "Fiat Accounts"
        self.accounts = accounts
    }
}
