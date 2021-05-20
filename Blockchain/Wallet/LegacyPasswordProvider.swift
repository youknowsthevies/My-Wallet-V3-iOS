// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SettingsKit

class LegacyPasswordProvider: LegacyPasswordProviding {
    func setLegacyPassword(_ legacyPassword: String?) {
        WalletManager.shared.legacyRepository.legacyPassword = legacyPassword
    }
}
