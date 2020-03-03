//
//  VerifyBackupScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxCocoa

final class VerifyBackupScreenPresenter {
    
    private typealias AccessibilityId = Accessibility.Identifier.Backup.VerifyBackup
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        return .none
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        return .back
    }
    
    var titleView: Screen.Style.TitleView {
        return .text(value: LocalizationConstants.VerifyBackupScreen.title)
    }
    
    var barStyle: Screen.Style.Bar {
        return .darkContent(ignoresStatusBar: false, background: .white)
    }
    
    // MARK: - Public Properties
    
    let verifyButtonViewModel: ButtonViewModel
    
    let firstTextFieldViewModel: ValidationTextFieldViewModel
    let secondTextFieldViewModel: ValidationTextFieldViewModel
    let thirdTextFieldViewModel: ValidationTextFieldViewModel
    
    let descriptionLabel: LabelContent
    let firstNumberLabel: LabelContent
    let secondNumberLabel: LabelContent
    let thirdNumberLabel: LabelContent
    let errorLabel: LabelContent
    
    // MARK: - Rx
    
    var errorDescriptionVisibility: Driver<Visibility> {
        return errorDescriptionVisibilityRelay.asDriver()
    }
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let errorDescriptionVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private unowned let stateService: BackupRouterStateServiceAPI
    
    // MARK: - Init
    
    init(stateService: BackupRouterStateService,
         service: RecoveryPhraseVerifyingServiceAPI,
         loadingViewPresenting: LoadingViewPresenting = LoadingViewPresenter.shared) {
        self.stateService = stateService
        
        let subset = service.selection
        let mnemonic = service.phraseComponents
        
        let firstIndex = mnemonic.firstIndex(of: subset[0]) ?? 0
        let secondIndex = mnemonic.firstIndex(of: subset[1]) ?? 0
        let thirdIndex = mnemonic.firstIndex(of: subset[2]) ?? 0
        
        firstNumberLabel = LabelContent(
            text: "\(firstIndex + 1)",
            font: .mainMedium(12.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityId.firstNumberLabel)
        )
        
        secondNumberLabel = LabelContent(
            text: "\(secondIndex + 1)",
            font: .mainMedium(12.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityId.secondNumberLabel)
        )
        
        thirdNumberLabel = LabelContent(
            text: "\(thirdIndex + 1)",
            font: .mainMedium(12.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityId.thirdNumberLabel)
        )
        
        errorLabel = LabelContent(
            text: LocalizationConstants.VerifyBackupScreen.errorDescription,
            font: .mainMedium(12.0),
            color: .destructive,
            accessibility: .id(AccessibilityId.errorLabel)
        )
        
        descriptionLabel = LabelContent(
            text: LocalizationConstants.VerifyBackupScreen.description,
            font: .mainMedium(14.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )
        
        firstTextFieldViewModel = ValidationTextFieldViewModel(
            with: .backupVerfication(index: firstIndex),
            validator: TextValidationFactory.word(value: subset[0])
        )
        
        secondTextFieldViewModel = ValidationTextFieldViewModel(
            with: .backupVerfication(index: secondIndex),
            validator: TextValidationFactory.word(value: subset[1])
        )
        
        thirdTextFieldViewModel = ValidationTextFieldViewModel(
            with: .backupVerfication(index: thirdIndex),
            validator: TextValidationFactory.word(value: subset[2])
        )
        
        verifyButtonViewModel = .primary(
            with: LocalizationConstants.VerifyBackupScreen.action,
            accessibilityId: AccessibilityId.verifyBackupButton
        )
        
        let isValidObservable = Observable.combineLatest(
            firstTextFieldViewModel.state,
            secondTextFieldViewModel.state,
            thirdTextFieldViewModel.state
            ).map { $0.0.isValid && $0.1.isValid && $0.2.isValid }
            
        isValidObservable
            .bind(to: verifyButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        // TODO: Handle the empty state. e.g. If all the fields are
        // empty, we shouldn't show the error label.
        isValidObservable
            .map { $0 == true ? .hidden : .visible }
            .bind(to: errorDescriptionVisibilityRelay)
            .disposed(by: disposeBag)
        
        verifyButtonViewModel
            .tapRelay
            .throttle(
                .milliseconds(500),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .show(
                loader: loadingViewPresenting,
                style: .circle,
                text: LocalizationConstants.syncingWallet
            )
            .bind(weak: self) { (self) in
                service.markBackupVerified()
                    .andThen(Observable.just(()))
                    .mapToVoid()
                    .hideLoaderOnDisposal(loader: loadingViewPresenting)
                    .bind(to: stateService.nextRelay)
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}
