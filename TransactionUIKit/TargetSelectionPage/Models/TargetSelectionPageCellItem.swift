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
        case singleAccount(AccountCurrentBalanceCellPresenter)
        case emptyDestination(SelectionButtonViewModel)
    }

    enum Interactor {
        case singleAccount(SingleAccount, AssetBalanceViewInteracting)
        case emptyDestination(SelectionButtonViewModel)
    }

    var identity: AnyHashable {
        guard let id = account?.id else {
            return UUID()
        }
        return id
    }

    let account: BlockchainAccount?
    let presenter: Presenter

    init(interactor: Interactor, assetAction: AssetAction) {
        switch interactor {
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
        case .emptyDestination(let viewModel):
            self.account = nil
            presenter = .emptyDestination(viewModel)
        }
    }
}
