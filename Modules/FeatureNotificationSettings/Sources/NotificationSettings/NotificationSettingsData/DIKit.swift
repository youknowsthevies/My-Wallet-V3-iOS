//
//  File.swift
//  
//
//  Created by Augustin Udrea on 19/04/2022.
//

import Foundation
import FeatureNotificationSettingsDomain
import DIKit
import NetworkKit

extension DependencyContainer {
    // MARK: - FeatureNotificationSettingsDomain Module
    
    public static var featureNotificationSettingsDataKit = module {
        factory { () -> NotificationSettingsRepositoryAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let client = NotificationsSettingsClient(networkAdapter: adapter, requestBuilder: builder)
            return NotificationSettingsRepository(client: client) as NotificationSettingsRepositoryAPI }
    }
}
