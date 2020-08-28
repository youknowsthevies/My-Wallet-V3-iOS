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

    let trailingButton: Screen.Style.TrailingButton = .close

    let leadingButton: Screen.Style.LeadingButton = .none

    let titleViewStyle: Screen.Style.TitleView = .text(value: LocalizationConstants.WalletPicker.title)

    var barStyle: Screen.Style.Bar {
        .darkContent()
    }

    var sectionObservable: Observable<[AccountPickerSectionViewModel]> {
        _ = setup
        return sectionRelay
            .map { AccountPickerSectionViewModel(items: $0) }
            .map { [$0] }
            .asObservable()
    }

    private let interactor: AccountPickerScreenInteractor
    private let sectionRelay = BehaviorRelay<[AccountPickerCellItem]>(value: [])
    private let disposeBag = DisposeBag()
    private let showTotalBalance: Bool

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

    public init(showTotalBalance: Bool, interactor: AccountPickerScreenInteractor) {
        self.interactor = interactor
        self.showTotalBalance = showTotalBalance
    }

    func record(selection: BlockchainAccount) {
        interactor.record(selection: selection)
    }
}
