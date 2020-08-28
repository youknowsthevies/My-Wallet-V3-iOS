//
//  AccountPickerScreenInteractor.swift
//  PlatformUIKit
//
//  Created by Paulo on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class AccountPickerScreenInteractor {

    var interactors: Observable<[AccountPickerCellItem.Interactor]> {
        let action = self.action
        return coincore.allAccounts
            .map { allAccountsGroup -> [BlockchainAccount] in
                [allAccountsGroup] + allAccountsGroup.accounts
            }
            .map { $0.filter { $0.actions.contains(action) } }
            .map { accounts -> [AccountPickerCellItem.Interactor] in
                accounts.map(\.accountPickerCellItemInteractor)
            }
            .asObservable()
    }

    private let action: AssetAction
    private let coincore: Coincore
    private let selectionService: AccountSelectionServiceAPI
    private let disposeBag = DisposeBag()

    public init(coincore: Coincore = resolve(),
                action: AssetAction,
                selectionService: AccountSelectionServiceAPI) {
        self.action = action
        self.coincore = coincore
        self.selectionService = selectionService
    }

    func record(selection: BlockchainAccount) {
        selectionService.record(selection: selection)
    }
}

fileprivate extension BlockchainAccount {
    var accountPickerCellItemInteractor: AccountPickerCellItem.Interactor {
        switch self {
        case is SingleAccount:
            let singleAccount = self as! SingleAccount
            return .singleAccount(singleAccount, AccountAssetBalanceViewInteractor(account: singleAccount))
        case is AccountGroup:
            let accountGroup = self as! AccountGroup
            return .accountGroup(
                accountGroup,
                AccountGroupBalanceCellInteractor(balanceViewInteractor: WalletBalanceViewInteractor(account: accountGroup))
            )
        default:
            impossible()
        }
    }
}
