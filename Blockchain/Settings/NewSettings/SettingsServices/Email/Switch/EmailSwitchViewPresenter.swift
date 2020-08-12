//
//  EmailSwitchViewPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class EmailSwitchViewPresenter: SwitchViewPresenting {
    
    // MARK: - Types
    
    private typealias AccessibilityID = Accessibility.Identifier.Settings.SwitchView
    private typealias AnalyticsEvent = AnalyticsEvents.Settings
    
    // MARK: - Public
    
    let viewModel = SwitchViewModel.primary(accessibilityId: AccessibilityID.twoFactorSwitchView)
    
    // MARK: - Private
    
    private let interactor: SwitchViewInteracting
    private let disposeBag = DisposeBag()
    
    init(service: EmailNotificationSettingsServiceAPI,
         analyticsRecording: AnalyticsEventRecording = resolve()) {
        interactor = EmailSwitchViewInteractor(service: service)
        
        viewModel.isSwitchedOnRelay
            .bindAndCatch(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)
        
        viewModel.isSwitchedOnRelay
            .bind { analyticsRecording.record(event: AnalyticsEvent.settingsEmailNotifSwitch(value: $0)) }
            .disposed(by: disposeBag)
        
        interactor.state
            .compactMap { $0.value }
            .map { $0.isEnabled }
            .bindAndCatch(to: viewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        interactor.state
            .compactMap { $0.value }
            .map { $0.isOn }
            .bindAndCatch(to: viewModel.isOnRelay)
            .disposed(by: disposeBag)
    }
}

