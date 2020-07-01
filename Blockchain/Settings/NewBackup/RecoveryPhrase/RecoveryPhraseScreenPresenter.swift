//
//  RecoveryPhraseScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift

final class RecoveryPhraseScreenPresenter {
    
    private typealias AccessibilityId = Accessibility.Identifier.Backup.RecoveryPhrase
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        .none
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        .back
    }
    
    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationConstants.RecoveryPhraseScreen.title)
    }
    
    var barStyle: Screen.Style.Bar {
        .darkContent()
    }
    
    // MARK: - View Models
    
    let recoveryViewModel: RecoveryPhraseViewModel
    let nextViewModel: ButtonViewModel
    let title = LocalizationConstants.RecoveryPhraseScreen.title
    let subtitle: LabelContent
    let description: LabelContent
        
    // MARK: - Injected
    
    private let stateService: BackupRouterStateService
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(stateService: BackupRouterStateService,
         serviceProvider: BackupFundsServiceProviderAPI) {
        self.stateService = stateService
        
        recoveryViewModel = RecoveryPhraseViewModel(
            mnemonicAPI: serviceProvider.mnemonicAccessAPI,
            mnemonicComponentsProviding: serviceProvider.mnemonicComponentsProviding
        )
        
        nextViewModel = .primary(
            with: LocalizationConstants.RecoveryPhraseScreen.next,
            accessibilityId: AccessibilityId.clipboardButton
        )
        
        subtitle = LabelContent(
            text: LocalizationConstants.RecoveryPhraseScreen.subtitle,
            font: .main(.semibold, 20.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityId.subtitleLabel)
        )
        
        description = LabelContent(
            text: LocalizationConstants.RecoveryPhraseScreen.description,
            font: .main(.medium, 14.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )
        
        nextViewModel.tapRelay
            .withLatestFrom(serviceProvider.mnemonicComponentsProviding.components)
            .bind { components in
                serviceProvider.recoveryPhraseVerifyingAPI.phraseComponents = components
                serviceProvider.recoveryPhraseVerifyingAPI.selection = components.pick(3)
                stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)
    }
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}
