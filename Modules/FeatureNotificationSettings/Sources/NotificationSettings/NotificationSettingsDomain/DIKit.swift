//
//  File.swift
//  
//
//  Created by Augustin Udrea on 15/04/2022.
//

import DIKit

extension DependencyContainer {
    // MARK: - FeatureNotificationSettingsDomain Module
    public static var featureNotificationSettingsDomainKit = module {
        single { ContactLanguagePreferenceService() as ContactLanguagePreferenceServiceAPI }
    }
}
