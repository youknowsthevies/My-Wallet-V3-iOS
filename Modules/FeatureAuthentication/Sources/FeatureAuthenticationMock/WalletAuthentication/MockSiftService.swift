// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain

final class MockSiftService: SiftServiceAPI {

    var enableCalled = false
    var setUserIdCalled: (Bool, String?) = (false, nil)
    var removeUserIdCalled = false

    func enable() {
        enableCalled = true
    }

    func set(userId: String) {
        setUserIdCalled = (true, userId)
    }

    func removeUserId() {
        removeUserIdCalled = true
    }
}
