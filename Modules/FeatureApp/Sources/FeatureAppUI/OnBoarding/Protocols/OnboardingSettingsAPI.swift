// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

public protocol OnboardingSettingsAPI {
    var walletIntroLatestLocation: WalletIntroductionLocation? { get set }
    var firstRun: Bool { get set }

    func reset()
}
