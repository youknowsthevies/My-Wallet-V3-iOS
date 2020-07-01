//
//  BackupFundsScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import ToolKit

final class BackupFundsScreenPresenter {
    
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias AccessibilityId = Accessibility.Identifier.Backup.IntroScreen
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        switch entry {
        case .settings:
            return .none
        case .custody:
            return .close
        }
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        switch entry {
        case .settings:
            return .back
        case .custody:
            return .none
        }
    }
    
    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationConstants.BackupFundsScreen.title)
    }
    
    var barStyle: Screen.Style.Bar {
        .lightContent()
    }
    
    // MARK: - Public Properites
    
    let subtitle: LabelContent
    let primaryDescription: LabelContent
    let secondaryDescription: LabelContent
    
    let startBackupButton: ButtonViewModel
    
    // MARK: - Private Properties
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let disposeBag = DisposeBag()
    private let entry: BackupRouterEntry
    private unowned let stateService: BackupRouterStateServiceAPI
    
    // MARK: - Localization
    
    private typealias SettingsLocalizationIDs = LocalizationConstants.BackupFundsScreen.Settings
    private typealias CustodyLocalizationIDs = LocalizationConstants.BackupFundsScreen.CustodySend
    
    // MARK: - Init
    
    init(stateService: BackupRouterStateServiceAPI,
         entry: BackupRouterEntry,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared) {
        self.analyticsRecorder = analyticsRecorder
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
                    font: .main(.semibold, 20.0),
                    color: .textFieldText,
                    accessibility: .id(AccessibilityId.titleLabel)
                )
            primaryDescription = .init(
                text: SettingsLocalizationIDs.Description.partA,
                font: .main(.medium, 14.0),
                color: .textFieldText,
                accessibility: .id(AccessibilityId.descriptionLabel)
            )
            secondaryDescription = .init(
                text: SettingsLocalizationIDs.Description.partB,
                font: .main(.medium, 14.0),
                color: .textFieldText,
                accessibility: .id(AccessibilityId.secondaryDescriptionLabel)
            )
        case .custody:
            subtitle = .init(
                    text: CustodyLocalizationIDs.subtitle,
                    font: .main(.semibold, 20.0),
                    color: .textFieldText,
                    accessibility: .id(AccessibilityId.titleLabel)
                )
            primaryDescription = .init(
                text: CustodyLocalizationIDs.description,
                font: .main(.medium, 14.0),
                color: .textFieldText,
                accessibility: .id(AccessibilityId.descriptionLabel)
            )
            secondaryDescription = .empty
        }
        
        self.startBackupButton.tapRelay
            .bindAndCatch(weak: self) { (self) in
                if entry == .custody {
                    self.analyticsRecorder.record(event: AnalyticsEvent.sbBackupWalletCardClicked)
                }
                
                self.stateService.nextRelay.accept(())
            }
            .disposed(by: self.disposeBag)
    }
    
    func viewDidLoad() {
        guard entry == .custody else { return }
        analyticsRecorder.record(event: AnalyticsEvent.sbBackupWalletCardShown)
    }
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}
