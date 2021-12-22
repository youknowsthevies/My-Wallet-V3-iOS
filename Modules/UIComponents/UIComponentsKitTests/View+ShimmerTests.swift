// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SnapshotTesting
import SwiftUI
import UIComponentsKit
import XCTest

final class ViewShimmerTests: XCTestCase {

    private var view: some View {
        Text("Placeholder")
            .fixedSize()
    }

    func testShimmerEnabled() {
        let enabled = view.shimmer(enabled: true)
        assertSnapshot(matching: enabled, as: .image, record: false)
    }

    func testShimmerDisabled() {
        let disabled = view.shimmer(enabled: false)
        assertSnapshot(matching: disabled, as: .image, record: false)
    }

    func testShimmerCustomCornerRadius() {
        let enabled = view.shimmer(enabled: true, cornerRadius: 16.0)
        assertSnapshot(matching: enabled, as: .image, record: false)
    }

    func testShimmerCustomSizing() {
        let view = Text("").shimmer(width: 100, height: 100)
        assertSnapshot(matching: view, as: .image, record: false)
    }
}
