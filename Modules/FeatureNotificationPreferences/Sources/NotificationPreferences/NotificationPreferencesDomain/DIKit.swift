//
//  File.swift
//
//
//  Created by Augustin Udrea on 15/04/2022.
//

import DIKit

extension DependencyContainer {
    // MARK: - FeatureNotificationPreferencesDomain Module

    public static var FeatureNotificationPreferencesDomainKit = module {
        single { ContactLanguagePreferenceService() as ContactLanguagePreferenceServiceAPI }
    }
}
