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
    func fetchSettings() -> AnyPublisher<[NotificationPreference], NetworkError>
}
