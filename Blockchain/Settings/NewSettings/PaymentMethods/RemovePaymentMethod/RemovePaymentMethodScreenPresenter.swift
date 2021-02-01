//
//  RemovePaymentMethodScreenPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class RemovePaymentMethodScreenPresenter {
    
    // MARK: - Types

    typealias AccessibilityIDs = Accessibility.Identifier.Settings.RemovePaymentMethodScreen

    // MARK: - Public Properties
    
    let badgeImageViewModel: BadgeImageViewModel
    let titleLabelContent: LabelContent
    let descriptionLabelContent: LabelContent
    let removeButtonViewModel: ButtonViewModel
    
    var dismissal: Signal<Void> {
        dismissalRelay.asSignal()
    }
    
    // MARK: - Private Properties
    
    private let loadingViewPresenter: LoadingViewPresenting
    private let interactor: RemovePaymentMethodScreenInteractor
    
    private let dismissalRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    init(buttonLocalizedString: String,
         interactor: RemovePaymentMethodScreenInteractor,
         loadingViewPresenter: LoadingViewPresenting = resolve()) {
        self.loadingViewPresenter = loadingViewPresenter
        self.interactor = interactor
        
        titleLabelContent = LabelContent(
            text: interactor.data.title,
            font: .main(.semibold, 20),
            color: .titleText,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.title)
        )
        
        descriptionLabelContent = LabelContent(
            text: interactor.data.description,
            font: .main(.medium, 14),
            color: .descriptionText,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.description)
        )
        
        badgeImageViewModel = .default(
            with: interactor.data.image,
            accessibilityIdSuffix: AccessibilityIDs.badge
        )
        
        removeButtonViewModel = .destructive(with: buttonLocalizedString)
    }
    
    func viewDidLoad() {
        interactor.state
            .map { $0.isCalculating }
            .bindAndCatch(weak: self) { (self, isCalculating) in
                if isCalculating {
                    self.loadingViewPresenter.show(with: .circle, text: nil)
                } else {
                    self.loadingViewPresenter.hide()
                }
            }
            .disposed(by: disposeBag)
        
        interactor.state
            .filter { $0.isValue }
            .mapToVoid()
            .bindAndCatch(to: dismissalRelay)
            .disposed(by: disposeBag)
        
        removeButtonViewModel.tapRelay
            .bindAndCatch(to: interactor.triggerRelay)
            .disposed(by: disposeBag)
    }
}
