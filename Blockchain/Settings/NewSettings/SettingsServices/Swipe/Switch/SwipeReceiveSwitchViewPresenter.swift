//
//  SwipeReceiveSwitchViewPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit
import PlatformUIKit
import ToolKit

final class SwipeReceiveSwitchViewPresenter: SwitchViewPresenting {
    
    // MARK: - Types
    
    private typealias AccessibilityID = Accessibility.Identifier.Settings.SwitchView
    private typealias AnalyticsEvent = AnalyticsEvents.Settings
    
    // MARK: - Public
    
    let viewModel: SwitchViewModel = .primary(accessibilityId: AccessibilityID.swipeToReceive)
    
    // MARK: - Private
    
    private let interactor: SwitchViewInteracting
    private let disposeBag = DisposeBag()
    
    init(appSettings: BlockchainSettings.App,
         analyticsRecording: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        interactor = SwipeReceiveSwitchViewInteractor(
            appSettings: appSettings
        )
        
        viewModel.isSwitchedOnRelay
            .bindAndCatch(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)
        
        viewModel.isSwitchedOnRelay
            .bind { analyticsRecording.record(event: AnalyticsEvent.settingsSwipeToReceiveSwitch(value: $0)) }
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

