//
//  AccountPickerAccountProviding.swift
//  PlatformUIKit
//
//  Created by Paulo on 06/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

public protocol AccountPickerAccountProviding {
    var accounts: Single<[BlockchainAccount]> { get }
}

public class AccountPickerDefaultAccountProvider: AccountPickerAccountProviding {

    // MARK: - Private Properties

    private let action: AssetAction
    private let coincore: Coincore
    private let singleAccountsOnly: Bool

    // MARK: - Properties

    public var accounts: Single<[BlockchainAccount]> {
        let singleAccountsOnly = self.singleAccountsOnly
        return coincore.allAccounts
            .map { allAccountsGroup -> [BlockchainAccount] in
                if singleAccountsOnly {
                    return allAccountsGroup.accounts
                }
                return [allAccountsGroup] + allAccountsGroup.accounts
            }
            .flatMapFilter(action: action)
    }

    // MARK: - Init

    public init(singleAccountsOnly: Bool,
                coincore: Coincore = resolve(),
                action: AssetAction) {
        self.action = action
        self.coincore = coincore
        self.singleAccountsOnly = singleAccountsOnly
    }
}
