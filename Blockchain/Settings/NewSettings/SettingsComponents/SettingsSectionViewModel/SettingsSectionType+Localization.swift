//
//  SettingsSectionType+Localization.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension SettingsSectionType {
    var sectionTitle: String {
        switch self {
        case .profile:
            return LocalizationConstants.Settings.Section.profile
        case .preferences:
            return LocalizationConstants.Settings.Section.preferences
        case .connect:
            return LocalizationConstants.Settings.Section.walletConnect
        case .security:
            return LocalizationConstants.Settings.Section.security
        case .cards:
            return LocalizationConstants.Settings.Section.linkedCards
        case .about:
            return LocalizationConstants.Settings.Section.about
        }
    }
}
