// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class BottomSheetTests: XCTestCase {

    func testBottomSheet() {
        let view = BottomSheetView_Previews.previews
            .frame(width: 320, height: 650)

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }
}
