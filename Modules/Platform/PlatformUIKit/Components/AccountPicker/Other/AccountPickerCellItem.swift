// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxDataSources

struct AccountPickerCellItem: IdentifiableType {

    // MARK: - Properties

    enum Presenter {
        case linkedBankAccount(LinkedBankAccountCellPresenter)
        case accountGroup(AccountGroupBalanceCellPresenter)
        case singleAccount(AccountCurrentBalanceCellPresenter)
    }

    enum Interactor {
        case linkedBankAccount(LinkedBankAccount)
        case accountGroup(AccountGroup, AccountGroupBalanceCellInteractor)
        case singleAccount(SingleAccount, AssetBalanceViewInteracting)
    }

    var identity: AnyHashable {
        account.identifier
    }

    let account: BlockchainAccount
    let presenter: Presenter

    init(interactor: Interactor, assetAction: AssetAction) {
        switch interactor {
        case .linkedBankAccount(let account):
            self.account = account
            presenter = .linkedBankAccount(
                .init(account: account, action: assetAction)
            )
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
