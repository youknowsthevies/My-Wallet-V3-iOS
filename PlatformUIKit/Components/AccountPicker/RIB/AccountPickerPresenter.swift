//
//  AccountPickerPresenter.swift
//  PlatformUIKit
//
//  Created by Paulo on 21/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs
import RxCocoa
import RxSwift

protocol AccountPickerPresentable: Presentable {
    func connect(state: Driver<AccountPickerInteractor.State>) -> Driver<AccountPickerInteractor.Effects>
}

final class AccountPickerPresenter: Presenter<AccountPickerViewControllable>, AccountPickerPresentable {

    // MARK: - Private Properties

    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel
    private let headerModel: AccountPickerHeaderType

    // MARK: - Init

    init(viewController: AccountPickerViewControllable,
         action: AssetAction,
         navigationModel: ScreenNavigationModel,
         headerModel: AccountPickerHeaderType) {
        self.action = action
        self.navigationModel = navigationModel
        self.headerModel = headerModel
        super.init(viewController: viewController)
    }

    // MARK: - Methods

    func connect(state: Driver<AccountPickerInteractor.State>) -> Driver<AccountPickerInteractor.Effects> {
        let action = self.action
        let sections = state.map(\.interactors)
            .map { items -> [AccountPickerCellItem] in
                items.map { interactor in
                    AccountPickerCellItem(interactor: interactor, assetAction: action)
                }
            }
            .map { AccountPickerSectionViewModel(items: $0) }
            .map { [$0] }
            .startWith([])

        let headerModel = self.headerModel
        let navigationModel = self.navigationModel
        let presentableState = sections
            .map { sections -> AccountPickerPresenter.State in
                AccountPickerPresenter.State(
                    headerModel: headerModel,
                    navigationModel: navigationModel,
                    sections: sections
                )
            }
        return viewController.connect(state: presentableState)
    }
}

extension AccountPickerPresenter {
    struct State {
        var headerModel: AccountPickerHeaderType
        var navigationModel: ScreenNavigationModel
        var sections: [AccountPickerSectionViewModel]
    }
}
