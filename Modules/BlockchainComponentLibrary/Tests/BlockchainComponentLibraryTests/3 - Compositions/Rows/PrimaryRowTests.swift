@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class PrimaryRowTests: XCTestCase {

    func testSnapshot() {
        let view = VStack(spacing: 0) {
            PrimaryRow_Previews.previews
        }
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }

    func testRightToLeft() {
        let view = VStack(spacing: 0) {
            PrimaryRow_Previews.previews
        }
        .environment(\.layoutDirection, .rightToLeft)
        .fixedSize()

        assertSnapshot(matching: view, as: .image, record: false)
    }
}
