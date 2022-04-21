//
//  File.swift
//  
//
//  Created by Augustin Udrea on 19/04/2022.
//

import Foundation
import FeatureNotificationPreferencesDomain
import DIKit
import NetworkKit

extension DependencyContainer {
    // MARK: - FeatureNotificationPreferencesDomain Module
    
    public static var FeatureNotificationPreferencesDataKit = module {
        factory { () -> NotificationPreferencesRepositoryAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let client = NotificationsSettingsClient(networkAdapter: adapter, requestBuilder: builder)
            return NotificationPreferencesRepository(client: client) as NotificationPreferencesRepositoryAPI}
    }
}
