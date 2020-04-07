//
//  MobileCodeEntryScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 3/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit

final class MobileCodeEntryScreenPresenter {
    
    // MARK: - Private Types
    
    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.MobileCodeEntry
    private typealias LocalizationIDs = LocalizationConstants.Settings.MobileCodeEntry
    
    // MARK: - Public Properties
    
    let leadingButton: Screen.Style.LeadingButton = .back
    
    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationIDs.title)
    }
    
    var barStyle: Screen.Style.Bar {
        .darkContent(ignoresStatusBar: false, background: .white)
    }
    
    let descriptionContent: LabelContent
    let codeEntryTextFieldModel: TextFieldViewModel
    let changeNumberViewModel: ButtonViewModel
    let resendCodeViewModel: ButtonViewModel
    let confirmViewModel: ButtonViewModel
    
    // MARK: - Private Properties
    
    private let interactor: MobileCodeEntryInteractor
    private unowned let stateService: UpdateMobileStateServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(stateService: UpdateMobileStateServiceAPI,
         service: MobileSettingsServiceAPI & SettingsServiceAPI,
         loadingViewPresenting: LoadingViewPresenting = LoadingViewPresenter.shared) {
        self.interactor = MobileCodeEntryInteractor(service: service)
        self.stateService = stateService
        codeEntryTextFieldModel = .init(
            with: .oneTimeCode,
            validator: TextValidationFactory.General.notEmpty,
            messageRecorder: CrashlyticsRecorder()
        )
        
        descriptionContent = .init(
            text: LocalizationIDs.description,
            font: .mainMedium(14.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id(AccessibilityIDs.descriptionLabel)
        )
        
        changeNumberViewModel = .secondary(with: LocalizationIDs.changeNumber, accessibilityId: AccessibilityIDs.changeNumberButton)
        resendCodeViewModel = .secondary(with: LocalizationIDs.resendCode, accessibilityId: AccessibilityIDs.resendCodeButton)
        confirmViewModel = .primary(with: LocalizationIDs.confirm, accessibilityId: AccessibilityIDs.confirmButton)
        
        codeEntryTextFieldModel.state
            .compactMap { $0.value }
            .bind(to: interactor.contentRelay)
            .disposed(by: disposeBag)
        
        changeNumberViewModel.tapRelay
            .bind(to: stateService.previousRelay)
            .disposed(by: disposeBag)
        
        resendCodeViewModel.tapRelay
            .map { .resend }
            .bind(to: interactor.actionRelay)
            .disposed(by: disposeBag)
        
        confirmViewModel.tapRelay
            .map { .verify }
            .bind(to: interactor.actionRelay)
            .disposed(by: disposeBag)
        
        interactor.state
            .bind { interactionState in
                switch interactionState.isLoading {
                case true:
                    loadingViewPresenting.show(with: .circle, text: nil)
                case false:
                    loadingViewPresenting.hide()
                }
            }
            .disposed(by: disposeBag)
        
        interactor.state
            .map { $0.isReady }
            .bind(to:
                resendCodeViewModel.isEnabledRelay,
                confirmViewModel.isEnabledRelay
            )
            .disposed(by: disposeBag)
        
        interactor.state
            .filter { $0.isComplete }
            .mapToVoid()
            .bind(to: stateService.nextRelay)
            .disposed(by: disposeBag)
    }
}
