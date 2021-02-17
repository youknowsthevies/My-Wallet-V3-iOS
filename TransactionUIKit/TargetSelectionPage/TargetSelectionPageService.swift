//
//  TargetSelectionPageService.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 05/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// Types adopting the `TargetSelectionPageServiceAPI` protocol, should be able provide a `TargetSelectionPageInteractor.State` so that `TransactionPageInteractor` can proccess the information.
protocol TargetSelectionPageServiceAPI {
    /// A stream of `TargetSelectionPageInteractor.State`
    var state: Driver<TargetSelectionPageInteractor.State> { get }
}

final class TargetSelectionPageService: TargetSelectionPageServiceAPI {

    typealias State = TargetSelectionPageInteractor.State

    let state: Driver<TargetSelectionPageInteractor.State>

    init(accountProvider: SourceAndTargetAccountProviding) {
        let sourceItem = accountProvider.sourceAccount
            .map { account -> [TargetSelectionPageCellItem.Interactor] in
                guard let account = account else {
                    impossible()
                }
                return [.singleAccount(account, AccountAssetBalanceViewInteractor(account: account))]
            }

        let emptySelectionButton = Self.provideEmptySelectionButonViewModel()

        let destinationItem = accountProvider.destinationAccount
            .map { (target) -> [TargetSelectionPageCellItem.Interactor] in
                guard let target = target else {
                    return [.emptyDestination(emptySelectionButton)]
                }
                if let target = target as? CryptoAccount {
                    return [.singleAccount(target, AccountAssetBalanceViewInteractor(account: target))]
                }
                return [.emptyDestination(SelectionButtonViewModel())]
            }

        state = Observable.combineLatest(sourceItem.asObservable(), destinationItem)
            .map { (sourceItems, destinationItems) -> TargetSelectionPageInteractor.State in
                State(sourceInteractors: sourceItems, destinationInteractors: destinationItems, actionButtonEnabled: false)
            }
            .asDriverCatchError()
    }

    private static func provideEmptySelectionButonViewModel() -> SelectionButtonViewModel {
        let viewModel = SelectionButtonViewModel()
        viewModel.titleRelay.accept(LocalizationConstants.WalletPicker.selectAWallet)
        viewModel.leadingContentTypeRelay.accept(
            .image(
                .init(
                    name: "icon-plus",
                    background: .lightBlueBackground,
                    offset: 4,
                    cornerRadius: .round,
                    size: .init(edge: 32)
                )
            )
        )
        viewModel.verticalOffsetRelay.accept(Spacing.outer)
        return viewModel
    }
}
