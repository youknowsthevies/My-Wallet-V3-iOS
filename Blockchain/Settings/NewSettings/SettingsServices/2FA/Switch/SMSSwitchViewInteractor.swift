//
//  SMSSwitchViewInteractor.swift
//  Blockchain
//
//  Created by AlexM on 3/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import NetworkKit
import PlatformKit
import PlatformUIKit

final class SMSSwitchViewInteractor: SwitchViewInteracting {
    
    typealias InteractionState = LoadingState<SwitchInteractionAsset>
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    let switchTriggerRelay = PublishRelay<Bool>()
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    init(service: SMSTwoFactorSettingsServiceAPI & SettingsServiceAPI) {
        
        service.valueObservable
            .map { ValueCalculationState.value($0) }
            .map { .init(with: $0) }
            .startWith(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        switchTriggerRelay
            .map { _ in .loading }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        switchTriggerRelay
            .flatMap {
                service
                    .smsTwoFactorAuthentication(enabled: $0)
                    .andThen(Observable.just(()))
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

fileprivate extension LoadingState where Content == (SwitchInteractionAsset) {
    
    /// Initializer that receives the interaction state and
    /// maps it to `self`
    init(with state: ValueCalculationState<WalletSettings>) {
        switch state {
        case .calculating,
             .invalid:
            self = .loading
        case .value(let value):
            self = .loaded(next: .init(isOn: value.authenticator == .sms, isEnabled: value.isSMSVerified))
        }
    }
}

