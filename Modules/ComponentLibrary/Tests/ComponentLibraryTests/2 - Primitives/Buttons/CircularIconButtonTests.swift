// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SnapshotTesting
import XCTest

final class CircularIconButtonTexts: XCTestCase {

    let button = CircularIconButton(icon: .chevronLeft) {}

    func testDefault() {
        assertSnapshot(matching: button, as: .image)
    }

    func testDisabled() {
        assertSnapshot(matching: button.disabled(true), as: .image)
    }
}
