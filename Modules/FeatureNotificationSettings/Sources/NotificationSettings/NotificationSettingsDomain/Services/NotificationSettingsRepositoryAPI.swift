//
//  File.swift
//  
//
//  Created by Augustin Udrea on 15/04/2022.
//

import Foundation
import NetworkError
import Combine

public protocol NotificationSettingsRepositoryAPI {
    func fetchSettings() -> AnyPublisher<[NotificationPreference], NetworkError>
}
