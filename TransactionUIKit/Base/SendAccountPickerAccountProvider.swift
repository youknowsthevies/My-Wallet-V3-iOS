//
//  SendAccountPickerAccountProvider.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 2/18/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift

final class SendAccountPickerAccountProvider: AccountPickerAccountProviding {
    
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
            .map(weak: self) { (self, accounts) -> [BlockchainAccount] in
                switch self.action {
                case .send:
                    return accounts.filter { $0 is NonCustodialAccount }
                default:
                    fatalError("Only send supported.")
                }
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
