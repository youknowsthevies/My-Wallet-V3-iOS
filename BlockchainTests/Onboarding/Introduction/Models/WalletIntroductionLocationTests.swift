//
//  WalletIntroductionLocationTests.swift
//  BlockchainTests
//
//  Created by AlexM on 9/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import Blockchain

class WalletIntroductionLocationTests: XCTestCase {
    
    let dashboardHome = WalletIntroductionLocation(screen: .dashboard, position: .home)
    let dashboardSend = WalletIntroductionLocation(screen: .dashboard, position: .send)
    let dashboardSwap = WalletIntroductionLocation(screen: .dashboard, position: .swap)
    
    func testComparableLocations() {
        XCTAssertLessThan(dashboardSend, dashboardSwap)
    }
}
