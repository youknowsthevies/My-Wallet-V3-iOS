//
//  BiometrySwitchViewPresenter.swift
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

final class BiometrySwitchViewPresenter: SwitchViewPresenting {
    
    // MARK: - Types
    
    private typealias AccessibilityID = Accessibility.Identifier.Settings.SwitchView
    private typealias AnalyticsEvent = AnalyticsEvents.Settings
    
    // MARK: - Public
    
    let viewModel: SwitchViewModel = .primary(accessibilityId: AccessibilityID.BioSwitchView)
    
    // MARK: - Proviate
    
    private let interactor: BiometrySwitchViewInteractor
    private let disposeBag = DisposeBag()
    
    init(provider: BiometryProviding,
         settingsAuthenticating: AppSettingsAuthenticating,
         analyticsRecording: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        interactor = BiometrySwitchViewInteractor(provider: provider,
                                                  authenticationCoordinator: .shared,
                                                  settingsAuthenticating: settingsAuthenticating)
        
        Observable.combineLatest(viewModel.isSwitchedOnRelay,
                                 Observable.just(interactor.configurationStatus),
                                 Observable.just(interactor.supportedBiometryType))
            .flatMap(weak: self) { (self, values) -> Observable<Bool> in
                self.toggleBiometry(values.2, biometryStatus: values.1, isOn: values.0)
            }
            .bind(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)
        
        viewModel
            .isSwitchedOnRelay
            .bind(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)
        
        viewModel
            .isSwitchedOnRelay
            .bind { analyticsRecording.record(event: AnalyticsEvent.settingsBiometryAuthSwitch(value: $0)) }
            .disposed(by: disposeBag)
        
        interactor
            .state
            .compactMap { $0.value }
            .map { $0.isEnabled }
            .bind(to: viewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        interactor
            .state
            .compactMap { $0.value }
            .map { $0.isOn }
            .bind(to: viewModel.isOnRelay)
            .disposed(by: disposeBag)
    }
    
    func toggleBiometry(_ biometryType: Biometry.BiometryType, biometryStatus: Biometry.Status, isOn: Bool) -> Observable<Bool> {
        return Observable.create { observable -> Disposable in
            guard isOn else {
                observable.onNext(false)
                return Disposables.create()
            }
            
            if case let .unconfigurable(error) = biometryStatus {
                let accept = UIAlertAction(
                    title: LocalizationConstants.okString,
                    style: .cancel,
                    handler: { _ in
                        observable.onNext(false)
                    })
                AlertViewPresenter.shared
                    .standardNotify(
                        message: error.localizedDescription,
                        title: LocalizationConstants.Errors.error,
                        actions: [accept]
                )
                return Disposables.create()
            }
            
            let name = biometryType.localizedName ?? ""
            let biometryWarning = String(format: LocalizationConstants.Biometry.biometryWarning, name)
            let cancel = UIAlertAction(
                title: LocalizationConstants.cancel,
                style: .cancel,
                handler: { _ in
                    observable.onNext(false)
                })
            let accept = UIAlertAction(
                title: LocalizationConstants.continueString,
                style: .default,
                handler: { _ in
                    observable.onNext(true)
                })
            AlertViewPresenter.shared
                .standardNotify(
                    message: biometryWarning,
                    title: name,
                    actions: [cancel, accept]
            )
            return Disposables.create()
        }
    }
}
