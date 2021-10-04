// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureAccountPickerUI
import Localization
import SnapshotTesting
import SwiftUI
import UIComponentsKit
import XCTest

class HeaderViewTests: XCTestCase {

    func testNormal() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: ImageAsset.iconSend.image,
                tableTitle: "Select a Wallet"
            )
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }

    func testNormalNoImage() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: nil,
                tableTitle: "Select a Wallet"
            )
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }

    func testNormalNoTableTitle() {
        let view = HeaderView(
            viewModel: .normal(
                title: "Send Crypto Now",
                subtitle: "Choose a Wallet to send cypto from.",
                image: ImageAsset.iconSend.image,
                tableTitle: nil
            )
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }

    func testSimple() {
        let view = HeaderView(
            viewModel: .simple(
                subtitle: "Subtitle"
            )
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }

    func testNone() {
        let view = HeaderView(
            viewModel: .none
        )
        .fixedSize()

        assertSnapshot(matching: view, as: .image)
    }
}
