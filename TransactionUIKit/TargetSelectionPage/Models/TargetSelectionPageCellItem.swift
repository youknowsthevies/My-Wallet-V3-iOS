//
//  PairPageCellItem.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 02/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxDataSources

struct TargetSelectionPageCellItem: IdentifiableType {
    // MARK: - Properties

    enum Presenter {
        case radioSelection(RadioSelectionCellPresenter)
        case cardView(CardViewViewModel)
        case singleAccount(AccountCurrentBalanceCellPresenter)
    }

    enum Interactor {
        case singleAccountAvailableTarget(SingleAccount)
        case singleAccountSelection(SingleAccount)
        case singleAccount(SingleAccount, AssetBalanceViewInteracting)
        
        var account: SingleAccount {
            switch self {
            case .singleAccountAvailableTarget(let account):
                return account
            case .singleAccountSelection(let account):
                return account
            case .singleAccount(let account, _):
                return account
            }
        }
    }
    
    var isSelectable: Bool {
        switch presenter {
        case .radioSelection:
            return true
        case .singleAccount,
             .cardView:
            return false
        }
    }

    var identity: AnyHashable {
        switch presenter {
        case .cardView(let viewModel):
            return viewModel.identifier
        case .radioSelection,
             .singleAccount:
            guard let account = account else {
                fatalError("Expected an account")
            }
            return account.id
        }
    }

    let account: BlockchainAccount?
    let presenter: Presenter
    
    init(cardView: CardViewViewModel) {
        account = nil
        presenter = .cardView(cardView)
    }

    init(interactor: Interactor, assetAction: AssetAction) {
        switch interactor {
        case .singleAccountAvailableTarget(let account):
            self.account = account
            presenter = .radioSelection(
                RadioSelectionCellPresenter(
                    account: account
                )
            )
        case .singleAccountSelection(let account):
            self.account = account
            presenter = .radioSelection(
                RadioSelectionCellPresenter(
                    account: account,
                    selected: true
                )
            )
        case .singleAccount(let account, let interactor):
            self.account = account
            presenter = .singleAccount(
                AccountCurrentBalanceCellPresenter(
                    account: account,
                    assetAction: assetAction,
                    interactor: interactor,
                    separatorVisibility: .hidden
                )
            )
        }
    }
}
