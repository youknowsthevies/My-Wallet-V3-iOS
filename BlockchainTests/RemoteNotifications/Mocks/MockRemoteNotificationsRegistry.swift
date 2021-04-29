// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

@testable import Blockchain

final class MockRemoteNotificationsRegistry: UIApplicationRemoteNotificationsAPI {
    
    private(set) var isRegistered = false

    func registerForRemoteNotifications() {
        isRegistered = true
    }
}
