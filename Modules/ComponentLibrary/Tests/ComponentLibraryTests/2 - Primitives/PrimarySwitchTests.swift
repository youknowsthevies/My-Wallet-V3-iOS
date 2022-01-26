// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SnapshotTesting
import XCTest

final class PrimarySwitchTests: XCTestCase {
    func testPrimarySwitch() {
        let view = PrimarySwitch_Previews.previews

        assertSnapshot(matching: view, as: .image, record: false)
    }
}
