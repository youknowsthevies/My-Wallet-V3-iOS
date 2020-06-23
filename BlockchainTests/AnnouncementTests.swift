//
//  AnnouncementTests.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit
import PlatformKit
import XCTest

@testable import Blockchain

final class AnnouncementTests: XCTestCase {

    // MARK: PAX
    
    func testAlgorandAnnouncementShows() {
        let cache = MemoryCacheSuite()
        let announcement = AlgorandAnnouncement(
            cacheSuite: cache,
            dismiss: {},
            action: {}
        )
        XCTAssertTrue(announcement.shouldShow)
        XCTAssertFalse(announcement.isDismissed)
        
        announcement.markRemoved()
        
        XCTAssertFalse(announcement.shouldShow)
        XCTAssertTrue(announcement.isDismissed)
    }
    
    // MARK: PIT
    
    func testExchangeLinkingAnnouncementShows() {
        let cache = MemoryCacheSuite()
        let announcement = ExchangeLinkingAnnouncement(
            shouldShowExchangeAnnouncement: true,
            cacheSuite: cache,
            dismiss: {},
            action: {}
        )
        XCTAssertTrue(announcement.shouldShow)
        XCTAssertFalse(announcement.isDismissed)
        
        announcement.markRemoved()
        
        XCTAssertFalse(announcement.shouldShow)
        XCTAssertTrue(announcement.isDismissed)
    }
}
