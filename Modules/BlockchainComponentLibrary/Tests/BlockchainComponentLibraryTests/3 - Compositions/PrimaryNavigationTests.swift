// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class PrimaryNavigationTests: XCTestCase {

    private struct TestContainer: View {

        let backButtonColor: Color
        @State var secondViewActive: Bool

        var body: some View {
            PrimaryNavigationView {
                Group {
                    PrimaryNavigationLink(
                        destination: secondView,
                        isActive: $secondViewActive
                    ) {
                        Text("First")
                    }
                }
                .primaryNavigation(
                    leading: {
                        IconButton(icon: .user) {}
                    },
                    title: "First",
                    trailing: {
                        IconButton(icon: .qrCode) {}
                    }
                )
            }
            .environment(\.navigationBackButtonColor, backButtonColor)
        }

        @ViewBuilder private var secondView: some View {
            Text("Second")
                .primaryNavigation(
                    title: "Second",
                    trailing: {
                        IconButton(icon: .qrCode) {}
                    }
                )
        }
    }

    func testFirstView_iPhone8() {
        assertSnapshots(
            matching: TestContainer(
                backButtonColor: .semantic.primary,
                secondViewActive: false
            ),
            as: [
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )

        assertSnapshots(
            matching: TestContainer(
                backButtonColor: Color(light: .palette.dark400, dark: .palette.white),
                secondViewActive: false
            ),
            as: [
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }

    func testFirstView_iPhoneX() {
        assertSnapshots(
            matching: TestContainer(
                backButtonColor: .semantic.primary,
                secondViewActive: false
            ),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )

        assertSnapshots(
            matching: TestContainer(
                backButtonColor: Color(light: .palette.dark400, dark: .palette.white),
                secondViewActive: false
            ),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }

    func testSecondView_iPhone8() {
        assertSnapshots(
            matching: TestContainer(
                backButtonColor: .semantic.primary,
                secondViewActive: true
            ),
            as: [
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )

        assertSnapshots(
            matching: TestContainer(
                backButtonColor: Color(light: .palette.dark400, dark: .palette.white),
                secondViewActive: true
            ),
            as: [
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }

    func testSecondView_iPhoneX() {
        assertSnapshots(
            matching: TestContainer(
                backButtonColor: .semantic.primary,
                secondViewActive: true
            ),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )

        assertSnapshots(
            matching: TestContainer(
                backButtonColor: Color(light: .palette.dark400, dark: .palette.white),
                secondViewActive: true
            ),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }
}
