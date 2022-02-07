// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class AlertCardTests: XCTestCase {

    func testSnapshot() {
        let view = VStack(spacing: Spacing.baseline) {
            AlertCard_Previews.previews
        }
        .fixedSize()

        assertSnapshot(matching: view, as: .image(layout: .sizeThatFits), record: false)
    }
}
