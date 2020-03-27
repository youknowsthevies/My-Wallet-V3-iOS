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
        
        viewModel
            .isOn
            .drive(onNext: { (isOn) in
                self.didTap(isOn)
            })
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
    
    func didTap(_ isOn: Bool) {
        guard isOn else {
            interactor.enableBiometricsRelay.accept(false)
            return
        }
        
        switch interactor.configurationStatus {
        case .configurable(let biometryType):
            enableBiometry(biometryType)
        case .configured:
            /// Already enabled
            return
        case .unconfigurable(let error):
            showError(error)
        }
    }
    
    func showError(_ error: Error) {
        let act1 = UIAlertAction(
            title: LocalizationConstants.okString,
            style: .cancel,
            handler: { [weak self] _ in
                self?.viewModel.isOnRelay.accept(false)
        })
        AlertViewPresenter.shared
            .standardNotify(
                message: error.localizedDescription,
                title: LocalizationConstants.Errors.error,
                actions: [act1]
        )
    }
    
    func enableBiometry(_ biometryType: Biometry.BiometryType) {
        let name = biometryType.localizedName ?? ""
        let biometryWarning = String(format: LocalizationConstants.Biometry.biometryWarning, name)
        let act1 = UIAlertAction(
            title: LocalizationConstants.cancel,
            style: .cancel,
            handler: { [weak self] _ in
                self?.viewModel.isOnRelay.accept(false)
        })
        let act2 = UIAlertAction(
            title: LocalizationConstants.continueString,
            style: .default,
            handler: { [weak self] _ in
                self?.interactor.enableBiometricsRelay.accept(true)
        })
        AlertViewPresenter.shared
            .standardNotify(
                message: biometryWarning,
                title: name,
                actions: [act1, act2]
        )
    }
}
