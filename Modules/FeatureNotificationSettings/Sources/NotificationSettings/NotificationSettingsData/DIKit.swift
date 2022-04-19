//
//  File.swift
//  
//
//  Created by Augustin Udrea on 19/04/2022.
//

import Foundation
import FeatureNotificationSettingsDomain
import DIKit

extension DependencyContainer {
    // MARK: - FeatureNotificationSettingsDomain Module
    
    public static var featureNotificationSettingsDataKit = module {
        factory { NotificationSettingsRepository(client: DIKit
            .resolve()) as NotificationSettingsRepositoryAPI }
    }
}
