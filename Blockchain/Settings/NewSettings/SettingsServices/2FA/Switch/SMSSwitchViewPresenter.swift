//
//  SMSSwitchViewPresenter.swift
//  Blockchain
//
//  Created by AlexM on 3/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

class SMSSwitchViewPresenter: SwitchViewPresenting {
    
    private typealias AccessibilityID = Accessibility.Identifier.Settings.SwitchView
    
    let viewModel = SwitchViewModel.primary(accessibilityId: AccessibilityID.SMSSwitchView)
    
    private let interactor: SwitchViewInteracting
    private let disposeBag = DisposeBag()
    
    init(service: SMSTwoFactorSettingsServiceAPI & SettingsServiceAPI) {
        interactor = SMSSwitchViewInteractor(service: service)
        
        viewModel.isSwitchedOnRelay
            .bindAndCatch(to: interactor.switchTriggerRelay)
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
