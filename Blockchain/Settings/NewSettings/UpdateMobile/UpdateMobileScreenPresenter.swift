//
//  UpdateMobileScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxRelay
import RxSwift
import RxCocoa

final class UpdateMobileScreenPresenter {
    
    // MARK: - Types
    
    typealias BadgeItem = BadgeAsset.Value.Presentation.BadgeItem
    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.UpdateMobile
    private typealias LocalizationIDs = LocalizationConstants.Settings.UpdateMobile
    
    // MARK: - Public Properties
    
    let leadingButton: Screen.Style.LeadingButton = .back
    
    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationIDs.title)
    }
    
    var barStyle: Screen.Style.Bar {
        .darkContent(ignoresStatusBar: false, background: .white)
    }
    
    var badgeState: Observable<LoadingState<BadgeItem>> {
        badgeRelay.asObservable()
    }
    
    var continueVisibility: Driver<Visibility> {
        continueVisibilityRelay.asDriver()
    }
    
    var disable2FASMSVisibility: Driver<Visibility> {
        disable2FASMSVisibilityRelay.asDriver()
    }
    
    var updateVisibility: Driver<Visibility> {
        updateVisibilityRelay.asDriver()
    }
    
    let textField: TextFieldViewModel
    let descriptionLabel: LabelContent
    let disable2FALabel: LabelContent
    let continueButtonViewModel: ButtonViewModel
    let updateButtonViewModel: ButtonViewModel
    
    private let disable2FASMSVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let continueVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let updateVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let badgeRelay = BehaviorRelay<LoadingState<BadgeItem>>(value: .loading)
    private let setupInteractor: UpdateMobileScreenSetupInteractor
    private let submissionInteractor: UpdateMobileScreenInteractor
    private unowned let stateService: UpdateMobileStateServiceAPI
    private let disposeBag = DisposeBag()
    
    init(stateService: UpdateMobileStateServiceAPI,
         settingsAPI: MobileSettingsServiceAPI & SettingsServiceAPI = UserInformationServiceProvider.default.settings,
         loadingViewPresenting: LoadingViewPresenting = LoadingViewPresenter.shared) {
        self.stateService = stateService
        textField = .init(
            with: .mobile,
            validator: TextValidationFactory.Info.mobile,
            formatter: TextFormatterFactory.mobile,
            messageRecorder: CrashlyticsRecorder()
        )
        
        descriptionLabel = .init(
            text: LocalizationIDs.description,
            font: .main(.medium, 14.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityIDs.descriptionLabel)
        )
        
        disable2FALabel = .init(
            text: LocalizationIDs.disableSMS2FA,
            font: .main(.medium, 14.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityIDs.disable2FALabel)
        )
        
        continueButtonViewModel = .primary(with: "Continue", accessibilityId: AccessibilityIDs.continueButton)
        updateButtonViewModel = .primary(with: "Update", accessibilityId: AccessibilityIDs.updateButton)
        
        submissionInteractor = UpdateMobileScreenInteractor(service: settingsAPI)
        setupInteractor = UpdateMobileScreenSetupInteractor(service: settingsAPI)
        
        textField.state
            .compactMap { $0.value }
            .bindAndCatch(to: submissionInteractor.contentRelay)
            .disposed(by: disposeBag)
        
        setupInteractor.state
            .compactMap { $0.value }
            .map { $0.isSMSVerified ? .visible : .hidden }
            .bindAndCatch(to: updateVisibilityRelay)
            .disposed(by: disposeBag)
        
        setupInteractor.state
            .compactMap { $0.value }
            .map { $0.is2FAEnabled ? .visible : .hidden }
            .bindAndCatch(to: disable2FASMSVisibilityRelay)
            .disposed(by: disposeBag)
        
        setupInteractor.state
            .compactMap { $0.value }
            .map { !$0.is2FAEnabled }
            .bindAndCatch(to: textField.isEnabledRelay)
            .disposed(by: disposeBag)
        
        setupInteractor.state
            .compactMap { $0.value }
            .map { !$0.isSMSVerified ? .visible : .hidden }
            .bindAndCatch(to: continueVisibilityRelay)
            .disposed(by: disposeBag)
            
        setupInteractor.state
            .map { !$0.isLoading }
            .bindAndCatch(to: textField.isEnabledRelay)
            .disposed(by: disposeBag)
        
        setupInteractor.state
            .map { !$0.isLoading }
            .bind(to:
                continueButtonViewModel.isEnabledRelay,
                updateButtonViewModel.isEnabledRelay
            )
            .disposed(by: disposeBag)
        
        setupInteractor.state
            .compactMap { $0.value?.mobileNumber }
            .bindAndCatch(to: textField.textRelay)
            .disposed(by: disposeBag)
        
        setupInteractor.state
            .map { .init(with: $0) }
            .bindAndCatch(to: badgeRelay)
            .disposed(by: disposeBag)
        
    Observable.combineLatest(textField.state, setupInteractor.state)
            .compactMap { ($0.0, $0.1.value) }
            .map { $0.0.isValid && $0.1?.is2FAEnabled == false }
            .bind(to:
                continueButtonViewModel.isEnabledRelay,
                updateButtonViewModel.isEnabledRelay
            )
            .disposed(by: disposeBag)
        
        continueButtonViewModel.tapRelay
            .bindAndCatch(to: submissionInteractor.triggerRelay)
            .disposed(by: disposeBag)
        
        updateButtonViewModel.tapRelay
            .bindAndCatch(to: submissionInteractor.triggerRelay)
            .disposed(by: disposeBag)
        
        submissionInteractor.interactionState
            .map { $0 != .updating }
            .bindAndCatch(to: continueButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        submissionInteractor.interactionState
            .bindAndCatch(weak: self, onNext: { (self, state) in
                switch state {
                case .ready:
                    loadingViewPresenting.hide()
                case .updating:
                    loadingViewPresenting.show(with: .circle, text: nil)
                case .complete:
                    loadingViewPresenting.hide()
                    stateService.nextRelay.accept(())
                case .failed:
                    self.setupInteractor.setupTrigger.accept(())
                    loadingViewPresenting.hide()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension LoadingState where Content == BadgeAsset.Value.Presentation.BadgeItem {
    init(with state: LoadingState<UpdateMobileScreenSetupInteractor.InteractionModel>) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content.badgeItem
                )
            )
        }
    }
}

