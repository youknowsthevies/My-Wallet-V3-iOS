@testable import ComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class DestructivePrimaryButtonTests: XCTestCase {
    func testSnapshot() {
        let view = VStack(spacing: 5) {
            DestructivePrimaryButton_Previews.previews
        }
        .frame(width: 320)
        .fixedSize()
        .padding()

        assertSnapshots(
            matching: view,
            as: [
                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }
}
