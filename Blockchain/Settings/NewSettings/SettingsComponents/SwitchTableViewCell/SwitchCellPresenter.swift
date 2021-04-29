// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import SettingsKit
import ToolKit

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
    
    init(service: EmailNotificationSettingsServiceAPI) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.emailNotifications,
            descriptors: .settings
        )
        switchViewPresenting = EmailSwitchViewPresenter(service: service)
    }
}

class CloudBackupSwitchCellPresenter: SwitchCellPresenting {

    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell.CloudBackup
    private typealias LocalizedString = LocalizationConstants.Settings

    let accessibility: Accessibility = .id(AccessibilityId.title)
    let labelContentPresenting: LabelContentPresenting
    let switchViewPresenting: SwitchViewPresenting

    init(appSettings: BlockchainSettings.App, credentialsStore: CredentialsStoreAPI) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.cloudBackup,
            descriptors: .settings
        )
        switchViewPresenting = CloudBackupSwitchViewPresenter(
            appSettings: appSettings,
            credentialsStore: credentialsStore
        )
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
