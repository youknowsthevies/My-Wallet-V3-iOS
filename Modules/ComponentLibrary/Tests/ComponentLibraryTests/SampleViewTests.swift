// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SnapshotTesting
import XCTest

final class SampleViewTests: XCTestCase {

    func testSampleView() {
        let view = SampleView()
            .fixedSize()
        assertSnapshot(matching: view, as: .image)
    }
}
