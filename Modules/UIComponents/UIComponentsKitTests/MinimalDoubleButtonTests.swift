import SnapshotTesting
import SwiftUI
@testable import UIComponentsKit
import XCTest

final class MinimalDoubleButtonTests: XCTestCase {

    func testNormal() {
        let normal = MinimalDoubleButton(
            leftTitle: "Restore",
            leftAction: {},
            rightTitle: "Log In ->",
            rightAction: {}
        )
        .frame(width: 375)

        assertSnapshot(matching: normal, as: .image)
    }

    func testDisabled() {
        // iPhone 8, iOS 14.2 Simulator does not render this disabled.
        // When CI is updated to a newer simulator this test will begin working
        // (tested working correctly with iOS 14.5 simulator)
        let disabled = MinimalDoubleButton(
            leftTitle: "Restore",
            leftAction: {},
            rightTitle: "Log In ->",
            rightAction: {}
        )
        .disabled(true)
        .frame(width: 375)

        assertSnapshot(matching: disabled, as: .image)
    }

    func testImageEnabled() {
        let normal = MinimalDoubleButton(
            leftImage: .systemName("pencil"),
            leftTitle: "Restore",
            leftAction: {},
            rightImage: .systemName("applelogo"),
            rightTitle: "Log In ->",
            rightAction: {}
        )
        .frame(width: 375)

        assertSnapshot(matching: normal, as: .image)
    }

    func testImageDisabled() {
        // iPhone 8, iOS 14.2 Simulator does not render this disabled.
        // When CI is updated to a newer simulator this test will begin working
        // (tested working correctly with iOS 14.5 simulator)
        let disabled = MinimalDoubleButton(
            leftImage: .systemName("pencil"),
            leftTitle: "Restore",
            leftAction: {},
            rightImage: .systemName("applelogo"),
            rightTitle: "Log In ->",
            rightAction: {}
        )
        .disabled(true)
        .frame(width: 375)

        assertSnapshot(matching: disabled, as: .image)
    }
}
