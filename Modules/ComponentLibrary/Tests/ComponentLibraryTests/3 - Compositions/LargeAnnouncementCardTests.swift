// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class LargeAnnouncementCardTests: XCTestCase {

    func testSnapshot() {
        let view = VStack(spacing: Spacing.baseline) {
            LargeAnnouncementCard_Previews.previews
        }
        .frame(width: 375)
        .fixedSize()

        assertSnapshot(matching: view, as: .image(layout: .sizeThatFits), record: false)
    }
}
