//
//  AccountPickerScreenPresenter.swift
//  PlatformUIKit
//
//  Created by Paulo on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class AccountPickerScreenPresenter {

    // MARK: - Navigation Properties

    var trailingButton: Screen.Style.TrailingButton {
        navigationModel.trailingButton
    }

    var leadingButton: Screen.Style.LeadingButton {
        navigationModel.leadingButton
    }

    var titleViewStyle: Screen.Style.TitleView {
        navigationModel.titleViewStyle
    }

    var barStyle: Screen.Style.Bar {
        navigationModel.barStyle
    }

    let headerModel: AccountPickerHeaderModel?

    var sectionObservable: Observable<[AccountPickerSectionViewModel]> {
        _ = setup
        return sectionRelay
            .map { AccountPickerSectionViewModel(items: $0) }
            .map { [$0] }
            .asObservable()
    }

    private let navigationModel: ScreenNavigationModel
    private let interactor: AccountPickerScreenInteractor
    private let sectionRelay = BehaviorRelay<[AccountPickerCellItem]>(value: [])
    private let disposeBag = DisposeBag()

    private lazy var setup: Void = {
        interactor.interactors
            .map { items -> [AccountPickerCellItem] in
                items.map { interactor in
                    AccountPickerCellItem(interactor: interactor)
                }
            }
            .bindAndCatch(to: sectionRelay)
            .disposed(by: disposeBag)
    }()

    public init(interactor: AccountPickerScreenInteractor,
                headerModel: AccountPickerHeaderModel?,
                navigationModel: ScreenNavigationModel) {
        self.headerModel = headerModel
        self.interactor = interactor
        self.navigationModel = navigationModel
    }

    func record(selection: BlockchainAccount) {
        interactor.record(selection: selection)
    }
}
