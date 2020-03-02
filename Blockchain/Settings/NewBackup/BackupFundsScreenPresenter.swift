//
//  BackupFundsScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift

final class BackupFundsScreenPresenter {
    
    private typealias AccessibilityId = Accessibility.Identifier.Backup.IntroScreen
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        return .none
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        switch entry {
        case .settings:
            return .back
        case .custody:
            return .close
        }
    }
    
    var titleView: Screen.Style.TitleView {
        return .text(value: LocalizationConstants.BackupFundsScreen.title)
    }
    
    var barStyle: Screen.Style.Bar {
        return .lightContent(ignoresStatusBar: false, background: .navigationBarBackground)
    }
    
    // MARK: - Public Properites
    
    let subtitle: LabelContent
    let primaryDescription: LabelContent
    let secondaryDescription: LabelContent
    
    let startBackupButton: ButtonViewModel
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let entry: BackupRouterEntry
    private unowned let stateService: BackupRouterStateServiceAPI
    
    // MARK: - Localization
    
    private typealias SettingsLocalizationIDs = LocalizationConstants.BackupFundsScreen.Settings
    private typealias CustodyLocalizationIDs = LocalizationConstants.BackupFundsScreen.CustodySend
    
    // MARK: - Init
    
    init(stateService: BackupRouterStateServiceAPI, entry: BackupRouterEntry) {
        self.stateService = stateService
        self.entry = entry
        switch entry {
        case .settings:
            self.startBackupButton = .primary(with: SettingsLocalizationIDs.action, accessibilityId: AccessibilityId.nextButton)
        case .custody:
            self.startBackupButton = .primary(with: CustodyLocalizationIDs.action, accessibilityId: AccessibilityId.nextButton)
        }
        
        switch entry {
        case .settings:
            subtitle = .init(
                text: SettingsLocalizationIDs.subtitle,
                    font: .mainSemibold(20.0),
                    color: .textFieldText,
                    accessibility: .id(AccessibilityId.titleLabel)
                )
            primaryDescription = .init(
                text: SettingsLocalizationIDs.Description.partA,
                font: .mainMedium(14.0),
                color: .textFieldText,
                accessibility: .id(AccessibilityId.descriptionLabel)
            )
            secondaryDescription = .init(
                text: SettingsLocalizationIDs.Description.partB,
                font: .mainMedium(14.0),
                color: .textFieldText,
                accessibility: .id(AccessibilityId.secondaryDescriptionLabel)
            )
        case .custody:
            subtitle = .init(
                    text: CustodyLocalizationIDs.subtitle,
                    font: .mainSemibold(20.0),
                    color: .textFieldText,
                    accessibility: .id(AccessibilityId.titleLabel)
                )
            primaryDescription = .init(
                text: CustodyLocalizationIDs.description,
                font: .mainMedium(14.0),
                color: .textFieldText,
                accessibility: .id(AccessibilityId.descriptionLabel)
            )
            secondaryDescription = .empty
        }
        
        self.startBackupButton.tapRelay
        .bind(weak: self, onNext: { _ in
            self.stateService.nextRelay.accept(())
        })
        .disposed(by: self.disposeBag)
    }
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}
