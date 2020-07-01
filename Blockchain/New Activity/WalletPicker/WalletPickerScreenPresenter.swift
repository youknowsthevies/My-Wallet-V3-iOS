//
//  WalletPickerScreenPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class WalletPickerScreenPresenter {
    
    // MARK: - Navigation Properties
    
    let trailingButton: Screen.Style.TrailingButton = .close
    
    let leadingButton: Screen.Style.LeadingButton = .none
    
    let titleViewStyle: Screen.Style.TitleView = .text(value: LocalizationConstants.WalletPicker.title)
    
    var barStyle: Screen.Style.Bar {
        .darkContent()
    }
    
    var sectionObservable: Observable<[WalletPickerSectionViewModel]> {
        sectionRelay
            .map { WalletPickerSectionViewModel(items: $0) }
            .map { [$0] }
            .asObservable()
    }
    
    private let interactor: WalletPickerScreenInteractor
    private let sectionRelay = BehaviorRelay<[WalletPickerCellItem]>(value: [])
    private let disposeBag = DisposeBag()
    
    init(interactor: WalletPickerScreenInteractor) {
        self.interactor = interactor
        
        interactor
            .interactors
            .map { items -> [WalletPickerCellItem] in
                items.map { .init(cellInteractor: $0) }
            }
            .bindAndCatch(to: sectionRelay)
            .disposed(by: disposeBag)
    }
    
    func record(selection: WalletPickerSelection) {
        interactor.record(selection: selection)
    }
}
