// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SnapshotTesting
import UIComponentsKit
import XCTest

final class LoadingStateViewTests: XCTestCase {

    func testLoadingStateView() {
        let view = LoadingStateView(title: "Loading...")
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone8)), record: false)
    }
}
