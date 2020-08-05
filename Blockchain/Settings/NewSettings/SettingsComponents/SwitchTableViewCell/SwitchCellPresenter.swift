//
//  SwitchCellPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/7/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift

protocol SwitchCellPresenting {
    var accessibility: Accessibility { get }
    var labelContentPresenting: LabelContentPresenting { get }
    var switchViewPresenting: SwitchViewPresenting { get }
}

class EmailNotificationsSwitchCellPresenter: SwitchCellPresenting {
    
    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell
    
    let accessibility: Accessibility = .id(AccessibilityId.EmailNotifications.title)
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting
    
    init(service: EmailNotificationSettingsServiceAPI & SettingsServiceAPI) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.emailNotifications,
            descriptors: .settings
        )
        switchViewPresenting = EmailSwitchViewPresenter(service: service)
    }
}

class SMSTwoFactorSwitchCellPresenter: SwitchCellPresenting {
    
    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell
    
    let accessibility: Accessibility = .id(AccessibilityId.TwoStepVerification.title)
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting
    
    init(service: SMSTwoFactorSettingsServiceAPI & SettingsServiceAPI) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.twoFactorAuthentication,
            descriptors: .settings
        )
        switchViewPresenting = SMSSwitchViewPresenter(service: service)
    }
}

class BalanceSharingSwitchCellPresenter: SwitchCellPresenting {
    
    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell
    
    let accessibility: Accessibility = .id(AccessibilityId.BalanceSharing.title)
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting
    
    init(service: BalanceSharingSettingsServiceAPI) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.balanceSharing,
            descriptors: .settings
        )
        switchViewPresenting = BalanceSharingSwitchViewPresenter(service: service)
    }
}

class BioAuthenticationSwitchCellPresenter: SwitchCellPresenting {
    
    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell
    
    let accessibility: Accessibility = .id(AccessibilityId.BioAuthentication.title)
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting
    
    init(biometryProviding: BiometryProviding,
         appSettingsAuthenticating: AppSettingsAuthenticating) {
        labelContentPresenting = BiometryLabelContentPresenter(
            provider: biometryProviding,
            descriptors: .settings
        )
        switchViewPresenting = BiometrySwitchViewPresenter(provider: biometryProviding, settingsAuthenticating: appSettingsAuthenticating)
    }
}

class SwipeReceiveSwitchCellPresenter: SwitchCellPresenting {
    
    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell
    
    let accessibility: Accessibility = .id(AccessibilityId.SwipeToReceive.title)
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting
    
    init(appSettings: BlockchainSettings.App) {
        
        switchViewPresenting = SwipeReceiveSwitchViewPresenter(appSettings: appSettings)
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.swipeToReceive,
            descriptors: .settings
        )
    }
}
