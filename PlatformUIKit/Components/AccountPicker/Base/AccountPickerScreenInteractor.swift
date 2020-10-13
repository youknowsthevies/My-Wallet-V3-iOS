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

    // MARK: Properties

    var interactors: Observable<[AccountPickerCellItem.Interactor]> {
        _ = setup
        let action = self.action
        let singleAccountsOnly = self.singleAccountsOnly
        return allAccountsRelay
            .asObservable()
            .compactMap { $0 }
            .map { allAccountsGroup -> [BlockchainAccount] in
                if singleAccountsOnly {
                    return allAccountsGroup.accounts
                }
                return [allAccountsGroup] + allAccountsGroup.accounts
            }
            .map { $0.filter { $0.actions.contains(action) } }
            .map { accounts -> [AccountPickerCellItem.Interactor] in
                accounts.map(\.accountPickerCellItemInteractor)
            }
            .asObservable()
    }

    let action: AssetAction

    // MARK: Private Properties

    private let allAccountsRelay = BehaviorRelay<AccountGroup?>(value: nil)
    private let coincore: Coincore
    private let selectionService: AccountSelectionServiceAPI
    private let disposeBag = DisposeBag()
    private let singleAccountsOnly: Bool

    private lazy var setup: Void = {
        coincore.allAccounts
            .subscribe(onSuccess: { [weak self] accountGroup in
                self?.allAccountsRelay.accept(accountGroup)
            })
            .disposed(by: disposeBag)
    }()

    public init(singleAccountsOnly: Bool,
                coincore: Coincore = resolve(),
                action: AssetAction,
                selectionService: AccountSelectionServiceAPI = AccountSelectionService()) {
        self.singleAccountsOnly = singleAccountsOnly
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
