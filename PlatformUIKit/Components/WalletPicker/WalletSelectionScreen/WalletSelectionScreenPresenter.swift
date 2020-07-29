//
//  WalletSelectionScreenPresenter.swift
//  PlatformUIKit
//
//  Created by Paulo on 28/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class WalletSelectionScreenPresenter {

    var sectionObservable: Observable<[WalletPickerSectionViewModel]> {
        _ = setup
        return sectionRelay
            .map { WalletPickerSectionViewModel(items: $0) }
            .map { [$0] }
            .asObservable()
    }
    
    private let interactor: WalletPickerInteractor
    private let sectionRelay = BehaviorRelay<[WalletPickerCellItem]>(value: [])
    private let disposeBag = DisposeBag()
    private let showTotalBalance: Bool

    private lazy var setup: Void = {
        let cellInteractors = showTotalBalance ? interactor.interactors : interactor.balanceCellInteractors
        cellInteractors
            .map { items -> [WalletPickerCellItem] in
                items.map { .init(cellInteractor: $0) }
            }
            .bindAndCatch(to: sectionRelay)
            .disposed(by: disposeBag)
    }()
    
    public init(showTotalBalance: Bool, interactor: WalletPickerInteractor) {
        self.interactor = interactor
        self.showTotalBalance = showTotalBalance
    }
    
    func record(selection: WalletPickerSelection) {
        interactor.record(selection: selection)
    }
}
