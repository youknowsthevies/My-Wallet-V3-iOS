// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SnapshotTesting
import XCTest

final class ChartBalanceTests: XCTestCase {

    func testChartBalance() {
        let view = ChartBalance_Previews.previews
            .fixedSize()

        assertSnapshot(matching: view, as: .image, record: false)
    }
}
