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
        assertSnapshot(matching: enabled, as: .image)
    }

    func testShimmerDisabled() {
        let disabled = view.shimmer(enabled: false)
        assertSnapshot(matching: disabled, as: .image)
    }

    func testShimmerCustomCornerRadius() {
        let enabled = view.shimmer(enabled: true, cornerRadius: 16.0)
        assertSnapshot(matching: enabled, as: .image)
    }
}
