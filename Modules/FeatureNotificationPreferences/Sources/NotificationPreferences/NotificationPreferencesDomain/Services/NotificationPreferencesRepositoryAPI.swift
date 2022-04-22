//
//  File.swift
//  
//
//  Created by Augustin Udrea on 15/04/2022.
//

import Foundation
import NetworkError
import Combine

public protocol NotificationPreferencesRepositoryAPI {
    func fetchPreferences() -> AnyPublisher<[NotificationPreference], NetworkError>
    func update(preferences: UpdatedPreferences) -> AnyPublisher<Void, NetworkError>
}
