//
//  AccountPickerCellItem.swift
//  PlatformUIKit
//
//  Created by Paulo on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxDataSources

struct AccountPickerCellItem: IdentifiableType {

    // MARK: - Properties

    enum Presenter {
        case accountGroup(AccountGroupBalanceCellPresenter)
        case singleAccount(AccountCurrentBalanceCellPresenter)
    }

    enum Interactor {
        case accountGroup(AccountGroup, AccountGroupBalanceCellInteractor)
        case singleAccount(SingleAccount, AssetBalanceViewInteracting)
    }

    var identity: AnyHashable {
        account.id
    }

    let account: BlockchainAccount
    let presenter: Presenter

    init(interactor: Interactor, assetAction: AssetAction) {
        switch interactor {
        case .singleAccount(let account, let interactor):
            self.account = account
            presenter = .singleAccount(
                AccountCurrentBalanceCellPresenter(
                    account: account,
                    assetAction: assetAction,
                    interactor: interactor
                )
            )
        case .accountGroup(let account, let interactor):
            self.account = account
            presenter = .accountGroup(
                AccountGroupBalanceCellPresenter(
                    account: account,
                    interactor: interactor
                )
            )
        }
    }
}
