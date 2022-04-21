//
//  File.swift
//  
//
//  Created by Augustin Udrea on 21/04/2022.
//

import Foundation
import NetworkKit
import Combine
import NetworkError
import DIKit
import NabuNetworkError

public protocol UpdateContactPreferencesServiceAPI: AnyObject {
    func update(_ preferences: [UpdatedNotificationPreference]
    ) -> AnyPublisher<Void, NabuNetworkError>
}
