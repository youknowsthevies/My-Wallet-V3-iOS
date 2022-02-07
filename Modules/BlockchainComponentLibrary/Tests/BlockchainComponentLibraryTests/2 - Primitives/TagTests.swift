// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class TagTests: XCTestCase {

    func testTags() {
        let view = HStack { Tag_Previews.previews.fixedSize() }

        assertSnapshot(matching: view, as: .image, record: false)
    }
}
