// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SnapshotTesting
import XCTest

final class PrimarySliderTests: XCTestCase {
    func testSlider() {
        let view = PrimarySlider_Previews.previews
            .frame(width: 375)
            .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }
}
