//
//  EmailSwitchViewInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import NetworkKit
import PlatformKit
import PlatformUIKit

class EmailSwitchViewInteractor: SwitchViewInteracting {
    
    typealias InteractionState = LoadingState<SwitchInteractionAsset>
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    var switchTriggerRelay = PublishRelay<Bool>()
    
    private let service: EmailNotificationSettingsServiceAPI & SettingsServiceAPI
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    init(service: EmailNotificationSettingsServiceAPI & SettingsServiceAPI) {
        self.service = service
        
        service.valueObservable
            .map { ValueCalculationState.value($0) }
            .map { .init(with: $0) }
            .startWith(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        switchTriggerRelay
            .do(onNext: { [weak self] _ in
                self?.stateRelay.accept(.loading)
            })
            .flatMap(weak: self) { (self, result) -> Observable<Void> in
                self.service
                    .emailNotifications(enabled: result)
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
            let emailVerified = value.isEmailVerified
            let emailNotifications = value.isEmailNotificationsEnabled
            self = .loaded(next: .init(isOn: emailNotifications, isEnabled: emailVerified))
        }
    }
}
