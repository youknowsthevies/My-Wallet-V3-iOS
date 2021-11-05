@testable import ComponentLibrary
import SnapshotTesting
import XCTest

final class UIImageExtensionsTests: XCTestCase {

    func testCircled() throws {
        let image = try XCTUnwrap(Icon.chevronLeft.uiImage?.circled)

        assertSnapshot(matching: image, as: .image)
    }

    func testPadded() throws {
        let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let padded = try XCTUnwrap(Icon.chevronLeft.uiImage?.padded(by: insets))

        assertSnapshot(matching: padded, as: .image)
    }
}
