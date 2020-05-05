//
//  RecoveryPhraseScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import PlatformUIKit

final class RecoveryPhraseScreenPresenter {
    
    private typealias AccessibilityId = Accessibility.Identifier.Backup.RecoveryPhrase
    
    // MARK: - Private Properties
    
    private unowned let stateService: BackupRouterStateService
    private weak var services: BackupFundsServiceProviderAPI?
    private let disposeBag = DisposeBag()
    
    // MARK: - Public Properties
    
    let recoveryViewModel: RecoveryPhraseViewModel
    let nextViewModel: ButtonViewModel
    let title = LocalizationConstants.RecoveryPhraseScreen.title
    let subtitle: LabelContent
    let description: LabelContent
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        return .none
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        return .back
    }
    
    var titleView: Screen.Style.TitleView {
        return .text(value: LocalizationConstants.RecoveryPhraseScreen.title)
    }
    
    var barStyle: Screen.Style.Bar {
        return .darkContent(ignoresStatusBar: false, background: .white)
    }
    
    // MARK: - Init
    
    init(stateService: BackupRouterStateService,
         services: BackupFundsServiceProviderAPI) {
        self.stateService = stateService
        self.services = services
        self.recoveryViewModel = RecoveryPhraseViewModel(
            mnemonicAPI: services.mnemonicAccessAPI,
            mnemonicComponentsProviding: services.mnemonicComponentsProviding
        )
        self.nextViewModel = .primary(
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
        
        Observable.combineLatest(self.nextViewModel.tapRelay, services.mnemonicComponentsProviding.components)
            .bind { [weak self] in
                guard let self = self else { return }
                self.services?.recoveryPhraseVerifyingAPI.phraseComponents = $0.1
                self.services?.recoveryPhraseVerifyingAPI.selection = $0.1.pick(3)
                stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)
    }
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}
