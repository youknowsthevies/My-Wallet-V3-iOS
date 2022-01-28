@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class ExchangeBuyButtonTests: XCTestCase {
    func testSnapshot() {
        let view = VStack(spacing: 5) {
            ExchangeBuyButton_Previews.previews
        }
        .frame(width: 320)
        .fixedSize()
        .padding()

        assertSnapshots(
            matching: view,
            as: [
                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }
}
