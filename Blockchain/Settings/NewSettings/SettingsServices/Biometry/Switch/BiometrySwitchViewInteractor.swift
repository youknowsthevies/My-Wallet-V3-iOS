//
//  BiometrySwitchViewInteractor.swift
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

class BiometrySwitchViewInteractor: SwitchViewInteracting {

    typealias InteractionState = LoadingState<SwitchInteractionAsset>

    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }

    var switchTriggerRelay = PublishRelay<Bool>()
    var enableBiometricsRelay = PublishRelay<Bool>()

    var configurationStatus: Biometry.Status {
        return provider.configurationStatus
    }

    var supportedBiometryType: Biometry.BiometryType {
        return provider.supportedBiometricsType
    }

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    private let provider: BiometryProviding

    init(provider: BiometryProviding, authenticationCoordinator: AuthenticationCoordinator, settingsAuthenticating: AppSettingsAuthenticating) {
        self.provider = provider

        enableBiometricsRelay
            .do(onNext: {
                if $0 {
                    authenticationCoordinator.enableBiometrics()
                } else {
                    settingsAuthenticating.pin = nil
                    settingsAuthenticating.biometryEnabled = false
                }
            })
            .subscribe()
            .disposed(by: disposeBag)

        Observable
            .just(settingsAuthenticating.biometryEnabled)
            .map { .loaded(next: .init(isOn: $0, isEnabled: true)) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)

        switchTriggerRelay
            .map { .loaded(next: .init(isOn: $0, isEnabled: true)) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
