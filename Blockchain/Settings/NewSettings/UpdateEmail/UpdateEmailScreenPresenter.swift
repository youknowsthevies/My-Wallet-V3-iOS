//
//  UpdateEmailScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class UpdateEmailScreenPresenter {
    
    // MARK: - Types
    
    typealias BadgeItem = BadgeAsset.Value.Presentation.BadgeItem
    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.UpdateEmail
    private typealias LocalizationIDs = LocalizationConstants.Settings.UpdateEmail
    
    // MARK: - Public Properties
    
    var leadingButton: Screen.Style.LeadingButton {
        .back
    }
    
    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationIDs.title)
    }
    
    var barStyle: Screen.Style.Bar {
        .darkContent()
    }
    
    var badgeState: Observable<LoadingState<BadgeItem>> {
        badgeRelay.asObservable()
    }
    
    var resendVisibility: Driver<Visibility> {
        resendVisibilityRelay.asDriver()
    }
    
    let textField: TextFieldViewModel
    let updateButtonViewModel: ButtonViewModel
    let resendButtonViewModel: ButtonViewModel
    let descriptionContent: LabelContent
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let resendVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let badgeRelay = BehaviorRelay<LoadingState<BadgeItem>>(value: .loading)
    private let interactor: UpdateEmailScreenInteractor
    
    init(emailScreenInteractor: UpdateEmailScreenInteractor,
         loadingViewPresenting: LoadingViewPresenting = LoadingViewPresenter.shared) {
        self.interactor = emailScreenInteractor
        textField = .init(
            with: .email,
            validator: TextValidationFactory.Info.email,
            messageRecorder: CrashlyticsRecorder()
        )

        descriptionContent = .init(
            text: LocalizationIDs.description,
            font: .main(.medium, 14.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id(AccessibilityIDs.descriptionLabel)
        )
        
        updateButtonViewModel = .primary(with: LocalizationIDs.update, accessibilityId: AccessibilityIDs.updateEmailButton)
        resendButtonViewModel = .secondary(with: LocalizationIDs.resend, accessibilityId: AccessibilityIDs.resendEmailButton)
        
        resendButtonViewModel.tapRelay
            .bind(to: interactor.resendRelay)
            .disposed(by: disposeBag)
        
        updateButtonViewModel.tapRelay
            .bind(to: interactor.triggerRelay)
            .disposed(by: disposeBag)
        
        textField.state
            .map { $0.isValid }
            .bind(to: updateButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        textField.state
            .compactMap { $0.value }
            .bind(to: interactor.contentRelay)
            .disposed(by: disposeBag)
        
        interactor.interactionState
            .compactMap { $0.value }
            .map { $0.values.isEmailVerified }
            .map { $0 ? .hidden : .visible }
            .bind(to: resendVisibilityRelay)
            .disposed(by: disposeBag)
        
        interactor.interactionState
            .filter { $0.value?.state != .updating }
            .compactMap { $0.value }
            .map { $0.values.email }
            .bind(to: textField.textRelay)
            .disposed(by: disposeBag)
        
        interactor.interactionState
            .map { $0.isLoading }
            .bind(to: updateButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
         let interactionStateValue = interactor.interactionState
            .compactMap { $0.value }
        
        Observable.combineLatest(interactionStateValue, textField.state)
            .map { (value) -> Bool in
                let interactionState = value.0.state
                let settingsValue = value.0.values.email
                let validEntry = value.1.isValid
                let currentEntry = value.1.value
                return (interactionState == .waiting || interactionState == .ready) && (validEntry && currentEntry == settingsValue)
            }
            .bind(to: resendButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        interactor.interactionState
            .compactMap { $0.value }
            .map { $0.state != .updating }
            .bind(to: updateButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        interactor.interactionState
            .map { .init(with: $0) }
            .bind(to: badgeRelay)
            .disposed(by: disposeBag)
        
        interactor.interactionState
            .compactMap { $0.value }
            .map { $0.state == .updating }
            .bind { value in
                switch value {
                case true:
                    loadingViewPresenting.show(with: .circle, text: nil)
                case false:
                    loadingViewPresenting.hide()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func viewWillDisappear() {
        interactor.cancelRelay.accept(())
    }
}

extension LoadingState where Content == BadgeAsset.Value.Presentation.BadgeItem {
    init(with state: LoadingState<UpdateEmailScreenInteractor.InteractionModel>) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content.values.badgeItem
                )
            )
        }
    }
}
