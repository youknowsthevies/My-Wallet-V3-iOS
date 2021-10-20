// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureSettingsDomain

extension DependencyContainer {

    // MARK: - FeatureSettingsData Module

    public static var featureSettingsData = module {

        // MARK: - NetworkClients

        factory { RecoveryPhraseExposureAlertClient() as RecoveryPhraseExposureAlertClientAPI }

        factory { RecoveryPhraseBackupClient() as RecoveryPhraseBackupClientAPI }

        // MARK: - Repositories

        factory { RecoveryPhraseRepository() as RecoveryPhraseRepositoryAPI }
    }
}
