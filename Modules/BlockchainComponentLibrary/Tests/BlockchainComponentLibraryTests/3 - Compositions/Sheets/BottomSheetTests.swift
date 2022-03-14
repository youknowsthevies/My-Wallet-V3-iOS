// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class BottomSheetTests: XCTestCase {

    func testBottomSheet() {

        let view = BottomSheetView {
            VStack {
                ForEach(1...10, id: \.self) { i in
                    Text("\(i * 2)")
                }
            }
        }
        .frame(width: 378, height: 768)
        .background(Color.gray)

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }
}
