//
//  SendAuxililaryViewPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class SendAuxililaryViewPresenter {
    
    // MARK: - Properties
    
    var maxButtonVisibility: Driver<Visibility> {
        Driver.just(buttonVisibility)
    }
    
    let availableBalanceContentViewPresenter: ContentLabelViewPresenter
    let maxButtonViewModel: ButtonViewModel
    
    private let buttonVisibility: Visibility
    private let disposeBag = DisposeBag()
    
    public init(interactor: SendAuxililaryViewInteractorAPI,
                availableBalanceTitle: String,
                maxButtonTitle: String,
                maxButtonVisibility: Visibility = .visible) {
        self.buttonVisibility = maxButtonVisibility
        availableBalanceContentViewPresenter = ContentLabelViewPresenter(
            title: availableBalanceTitle,
            interactor: interactor.availableBalanceContentViewInteractor
        )
        
        maxButtonViewModel = ButtonViewModel.secondary(
            with: maxButtonTitle,
            font: .main(.semibold, 14)
        )
        
        maxButtonViewModel.contentInsetRelay.accept(
            UIEdgeInsets(horizontal: Spacing.standard, vertical: 0)
        )
        
        maxButtonViewModel.tap
            .emit(to: interactor.resetToMaxAmountRelay)
            .disposed(by: disposeBag)
        
        availableBalanceContentViewPresenter.containsDescription
            .drive(maxButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
    }
}
