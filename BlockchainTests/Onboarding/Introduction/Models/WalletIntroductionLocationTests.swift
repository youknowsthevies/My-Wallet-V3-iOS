// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import XCTest

@testable import Blockchain

class WalletIntroductionLocationTests: XCTestCase {

    let dashboardSend = WalletIntroductionLocation(screen: .dashboard, position: .send)
    let dashboardSwap = WalletIntroductionLocation(screen: .dashboard, position: .swap)

    func testComparableLocations() {
        XCTAssertLessThan(dashboardSend, dashboardSwap)
    }
}
