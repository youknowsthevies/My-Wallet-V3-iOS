//
//  BalanceSharingSwitchViewPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 6/18/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class BalanceSharingSwitchViewPresenter: SwitchViewPresenting {
    
    // MARK: - Types
    
    private typealias AccessibilityID = Accessibility.Identifier.Settings.SwitchView
    
    // MARK: - Properties
    
    let viewModel = SwitchViewModel.primary(accessibilityId: AccessibilityID.balanceSync)
    
    private let interactor: SwitchViewInteracting
    private let disposeBag = DisposeBag()
    
    init(service: BalanceSharingSettingsServiceAPI) {
        interactor = BalanceSharingSwitchViewInteractor(service: service)
        
        viewModel.isSwitchedOnRelay
            .bind(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)
        
        interactor.state
            .compactMap { $0.value }
            .map { $0.isEnabled }
            .bind(to: viewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        interactor.state
            .compactMap { $0.value }
            .map { $0.isOn }
            .bind(to: viewModel.isOnRelay)
            .disposed(by: disposeBag)
    }
    
}
