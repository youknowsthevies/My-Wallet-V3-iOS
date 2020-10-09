//
//  WalletIntroductionLocationTests.swift
//  BlockchainTests
//
//  Created by AlexM on 9/3/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain
import XCTest

class WalletIntroductionLocationTests: XCTestCase {

    let dashboardSend = WalletIntroductionLocation(screen: .dashboard, position: .send)
    let dashboardSwap = WalletIntroductionLocation(screen: .dashboard, position: .swap)
    
    func testComparableLocations() {
        XCTAssertLessThan(dashboardSend, dashboardSwap)
    }
}
