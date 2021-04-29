//
//  LegacyPasswordProvider.swift
//  Blockchain
//
//  Created by Maciej Burda on 20/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import SettingsKit

class LegacyPasswordProvider: LegacyPasswordProviding {
    func setLegacyPassword(_ legacyPassword: String?) {
        WalletManager.shared.legacyRepository.legacyPassword = legacyPassword
    }
}
