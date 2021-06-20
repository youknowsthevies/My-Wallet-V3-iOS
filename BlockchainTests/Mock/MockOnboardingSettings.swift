// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain

class MockOnboardingSettings: OnboardingSettingsAPI {

    var walletIntroLatestLocation: WalletIntroductionLocation? = nil
    var firstRun: Bool = false

    var resetCalled = false
    func reset() {
        resetCalled = true
    }

    init() { }
}
