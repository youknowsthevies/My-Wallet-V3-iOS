//
//  AccountGroup.swift
//  PlatformKit
//
//  Created by Paulo on 03/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// A `BlockchainAccount` that represents a collection of accounts, opposed to a single account.
public protocol AccountGroup: BlockchainAccount {
    var accounts: [SingleAccount] { get }

    func includes(account: BlockchainAccount) -> Bool
}

extension AccountGroup {
    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        Single
            .zip(
                accounts.map { $0.fiatBalance(fiatCurrency: fiatCurrency) }
            )
            .map { moneyValues -> MoneyValue in
                try moneyValues.reduce(into: try MoneyValue(major: 0, currencyType: .fiat(fiatCurrency))) { (result, this) in
                    try result += this
                }
            }
    }

    public func includes(account: BlockchainAccount) -> Bool {
        accounts.map(\.id).contains(account.id)
    }

    public var actions: AvailableActions {
        accounts.map(\.actions).reduce(into: AvailableActions()) { $0.formUnion($1) }
    }
}

public enum AccountGroupError: Error {
    case noBalance
}
