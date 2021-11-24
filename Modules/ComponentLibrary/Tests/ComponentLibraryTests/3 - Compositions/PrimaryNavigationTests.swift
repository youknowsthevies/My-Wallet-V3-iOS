// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class PrimaryNavigationTests: XCTestCase {

    private struct TestContainer: View {
        let usesCircledBackButton: Bool
        @State var secondViewActive: Bool

        var body: some View {
            PrimaryNavigationView {
                PrimaryNavigationLink(
                    destination: secondView,
                    isActive: $secondViewActive
                ) {
                    Text("First")
                }
                .primaryNavigation(title: "First") {
                    IconButton(icon: .qrCode) {}

                    IconButton(icon: .user) {}
                }
            }
            .environment(\.navigationUsesCircledBackButton, usesCircledBackButton)
        }

        @ViewBuilder private var secondView: some View {
            Text("Second")
                .primaryNavigation(title: "Second") {
                    IconButton(icon: .qrCode) {}
                }
        }
    }

    func testFirstView_iPhone8() {
        assertSnapshots(
            matching: TestContainer(usesCircledBackButton: true, secondViewActive: false),
            as: [
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )

        assertSnapshots(
            matching: TestContainer(usesCircledBackButton: false, secondViewActive: false),
            as: [
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    func testFirstView_iPhoneX() {
        assertSnapshots(
            matching: TestContainer(usesCircledBackButton: true, secondViewActive: false),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )

        assertSnapshots(
            matching: TestContainer(usesCircledBackButton: false, secondViewActive: false),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    func testSecondView_iPhone8() {
        assertSnapshots(
            matching: TestContainer(usesCircledBackButton: true, secondViewActive: true),
            as: [
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )

        assertSnapshots(
            matching: TestContainer(usesCircledBackButton: false, secondViewActive: true),
            as: [
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    func testSecondView_iPhoneX() {
        assertSnapshots(
            matching: TestContainer(usesCircledBackButton: true, secondViewActive: true),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )

        assertSnapshots(
            matching: TestContainer(usesCircledBackButton: false, secondViewActive: true),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }
}
