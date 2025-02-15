// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SnapshotTesting
import UIComponentsKit
import XCTest

final class ErrorStateViewTests: XCTestCase {

    func testErrorStateView() {
        let view = ErrorStateView(title: "An error has occurred.")
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone8)), record: false)
    }

    func testRetryButton() {
        let view = ErrorStateView(
            title: "An error has occurred.",
            button: ("Retry", {})
        )

        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone8)), record: false)
    }
}
