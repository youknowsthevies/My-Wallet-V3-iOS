// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAppUI
import PlatformKit

@testable import Blockchain

class MockOnboardingSettings: OnboardingSettingsAPI {

    var walletIntroLatestLocation: WalletIntroductionLocation?
    var firstRun: Bool = false

    var resetCalled = false

    func reset() {
        resetCalled = true
    }

    init() {}
}
