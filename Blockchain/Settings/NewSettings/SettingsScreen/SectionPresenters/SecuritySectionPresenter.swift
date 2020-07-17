//
//  SecuritySectionPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift

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
                            .init(cellType: .plain(.changePassword)),
                            .init(cellType: .badge(.recoveryPhrase, recoveryCellPresenter)),
                            .init(cellType: .plain(.changePIN)),
                            .init(cellType: .switch(.bioAuthentication, bioAuthenticationCellPresenter)),
                            .init(cellType: .switch(.swipeToReceive, swipeToReceiveCellPresenter))
                        ]
                    )
                )
            )
        )
    }
    
    private let recoveryCellPresenter: RecoveryStatusCellPresenter
    private let bioAuthenticationCellPresenter: BioAuthenticationSwitchCellPresenter
    private let smsTwoFactorSwitchCellPresenter: SMSTwoFactorSwitchCellPresenter
    private let swipeToReceiveCellPresenter: SwipeReceiveSwitchCellPresenter
    
    init(smsTwoFactorService: SMSTwoFactorSettingsServiceAPI,
         biometryProvider: BiometryProviding,
         settingsAuthenticater: AppSettingsAuthenticating,
         recoveryPhraseStatusProvider: RecoveryPhraseStatusProviding,
         appSettings: BlockchainSettings.App = BlockchainSettings.App.shared) {
        self.smsTwoFactorSwitchCellPresenter = .init(service: smsTwoFactorService)
        self.bioAuthenticationCellPresenter = .init(biometryProviding: biometryProvider, appSettingsAuthenticating: settingsAuthenticater)
        self.recoveryCellPresenter = .init(recoveryStatusProviding: recoveryPhraseStatusProvider)
        self.swipeToReceiveCellPresenter = .init(appSettings: appSettings)
    }
}
