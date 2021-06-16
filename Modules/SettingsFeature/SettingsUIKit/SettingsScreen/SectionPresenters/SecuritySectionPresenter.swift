// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import SettingsKit

final class SecuritySectionPresenter: SettingsSectionPresenting {
    let sectionType: SettingsSectionType = .security

    var state: Observable<SettingsSectionLoadingState> {
        .just(
            .loaded(next:
                .some(
                    .init(
                        sectionType: sectionType,
                        items: [
                            .init(cellType: .switch(.sms2FA, smsTwoFactorSwitchCellPresenter)),
                            .init(cellType: .switch(.cloudBackup, cloudBackupSwitchCellPresenter)),
                            .init(cellType: .plain(.changePassword)),
                            .init(cellType: .badge(.recoveryPhrase, recoveryCellPresenter)),
                            .init(cellType: .plain(.changePIN)),
                            .init(cellType: .switch(.bioAuthentication, bioAuthenticationCellPresenter)),
                            .init(cellType: .switch(.balanceSyncing, balanceSyncingCellPresenter))
                        ]
                    )
                )
            )
        )
    }

    private let recoveryCellPresenter: RecoveryStatusCellPresenter
    private let bioAuthenticationCellPresenter: BioAuthenticationSwitchCellPresenter
    private let smsTwoFactorSwitchCellPresenter: SMSTwoFactorSwitchCellPresenter
    private let balanceSyncingCellPresenter: BalanceSharingSwitchCellPresenter
    private let cloudBackupSwitchCellPresenter: CloudBackupSwitchCellPresenter

    init(smsTwoFactorService: SMSTwoFactorSettingsServiceAPI,
         credentialsStore: CredentialsStoreAPI,
         biometryProvider: BiometryProviding,
         settingsAuthenticater: AppSettingsAuthenticating,
         recoveryPhraseStatusProvider: RecoveryPhraseStatusProviding,
         balanceSharingService: BalanceSharingSettingsServiceAPI,
         authenticationCoordinator: AuthenticationCoordinating,
         appSettings: BlockchainSettings.App = resolve()) {
        self.smsTwoFactorSwitchCellPresenter = SMSTwoFactorSwitchCellPresenter(
            service: smsTwoFactorService
        )
        self.bioAuthenticationCellPresenter = BioAuthenticationSwitchCellPresenter(
            biometryProviding: biometryProvider,
            appSettingsAuthenticating: settingsAuthenticater,
            authenticationCoordinator: authenticationCoordinator
        )
        self.recoveryCellPresenter = RecoveryStatusCellPresenter(
            recoveryStatusProviding: recoveryPhraseStatusProvider
        )
        self.balanceSyncingCellPresenter = BalanceSharingSwitchCellPresenter(
            service: balanceSharingService
        )
        self.cloudBackupSwitchCellPresenter = CloudBackupSwitchCellPresenter(
            appSettings: appSettings,
            credentialsStore: credentialsStore
        )
    }
}
