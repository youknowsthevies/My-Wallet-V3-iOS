@testable import ComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class ActionRowTests: XCTestCase {

    func testSnapshot() {
        let view = VStack(spacing: Spacing.baseline) {
            ActionRow_Previews.previews
        }
        .fixedSize()
        .padding()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }
}
