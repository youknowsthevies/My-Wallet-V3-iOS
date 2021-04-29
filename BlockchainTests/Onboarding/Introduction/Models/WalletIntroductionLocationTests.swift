// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import XCTest

class WalletIntroductionLocationTests: XCTestCase {

    let dashboardSend = WalletIntroductionLocation(screen: .dashboard, position: .send)
    let dashboardSwap = WalletIntroductionLocation(screen: .dashboard, position: .swap)
    
    func testComparableLocations() {
        XCTAssertLessThan(dashboardSend, dashboardSwap)
    }
}
