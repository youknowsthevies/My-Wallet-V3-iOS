//
//  AccountPickerInteractor.swift
//  PlatformUIKit
//
//  Created by Paulo on 21/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public protocol AccountPickerRouting: ViewableRouting {
    // Declare methods the interactor can invoke to manage sub-tree via the router.
}

final class AccountPickerInteractor: PresentableInteractor<AccountPickerPresentable>, AccountPickerInteractable {

    // MARK: - Properties

    weak var router: AccountPickerRouting?

    // MARK: - Private Properties

    private let action: AssetAction
    private let coincore: Coincore
    private let didSelect: AccountPickerDidSelect
    private let disposeBag = DisposeBag()
    private let singleAccountsOnly: Bool

    // MARK: - Init

    init(presenter: AccountPickerPresentable,
         singleAccountsOnly: Bool,
         coincore: Coincore = resolve(),
         action: AssetAction,
         didSelect: @escaping AccountPickerDidSelect) {
        self.action = action
        self.coincore = coincore
        self.didSelect = didSelect
        self.singleAccountsOnly = singleAccountsOnly
        super.init(presenter: presenter)
    }

    // MARK: - Methods

    override func didBecomeActive() {
        super.didBecomeActive()

        let action = self.action
        let singleAccountsOnly = self.singleAccountsOnly

        let interactorState: Driver<State> = coincore.allAccounts
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
            .map { (interactors) -> State in
                State(interactors: interactors)
            }
            .asDriver(onErrorJustReturn: .empty)

        presenter.connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    // MARK: - Private methods

    private func handle(effects: Effects) {
        switch effects {
        case .select(let account):
            didSelect(account)
        case .none:
            break
        }
    }
}

extension AccountPickerInteractor {
    struct State {
        static let empty = State(interactors: [])
        let interactors: [AccountPickerCellItem.Interactor]
    }

    enum Effects {
        case select(BlockchainAccount)
        case none
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
