//
//  TargetSelectionPageService.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 05/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
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

    init(accountProvider: SourceAndTargetAccountProviding,
         action: AssetAction,
         coincore: Coincore = resolve()) {
        let sourceItem = accountProvider.sourceAccount
            .map { account -> [TargetSelectionPageCellItem.Interactor] in
                guard let account = account else {
                    impossible()
                }
                return [.singleAccount(account, AccountAssetBalanceViewInteractor(account: account))]
            }
        
        let destinationItem = accountProvider
            .sourceAccount
            .map { account in
                guard let crypto = account else {
                    impossible()
                }
                return crypto
            }
            .flatMap { (source) -> Single<[SingleAccount]> in
                coincore.getTransactionTargets(sourceAccount: source, action: action)
            }
            .map { accounts -> [TargetSelectionPageCellItem.Interactor] in
                let cryptoAccounts = accounts.compactMap { $0 as? CryptoAccount }
                return cryptoAccounts.map { crypto in
                    .singleAccount(crypto, AccountAssetBalanceViewInteractor(account: crypto))
                }
            }
            .asObservable()
            
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
