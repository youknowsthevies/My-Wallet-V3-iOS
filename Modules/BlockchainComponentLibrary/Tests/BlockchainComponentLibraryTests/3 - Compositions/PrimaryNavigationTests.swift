// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class PrimaryNavigationTests: XCTestCase {

    private struct TestContainer: View {
        let backButtonColor: Color
        @State var secondViewActive: Bool
        let icon: Icon?
        let byline: String?
        let isLargeTitle: Bool

        var body: some View {
            PrimaryNavigationView {
                PrimaryNavigationLink(
                    destination: secondView,
                    isActive: $secondViewActive
                ) {
                    Text("First")
                }
                .primaryNavigation(
                    icon: { icon?.accentColor(.semantic.muted) },
                    title: "First",
                    isLargeTitle: isLargeTitle,
                    byline: byline,
                    trailing: {
                        IconButton(icon: .qrCode) {}

                        IconButton(icon: .user) {}
                    }
                )
            }
            .environment(\.navigationBackButtonColor, backButtonColor)
        }

        @ViewBuilder private var secondView: some View {
            Text("Second")
                .primaryNavigation(
                    icon: { icon?.accentColor(.semantic.muted) },
                    title: "Second",
                    byline: byline,
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
                secondViewActive: false,
                icon: nil,
                byline: nil,
                isLargeTitle: true
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
                secondViewActive: false,
                icon: nil,
                byline: nil,
                isLargeTitle: true
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
                secondViewActive: false,
                icon: nil,
                byline: nil,
                isLargeTitle: true
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
                secondViewActive: false,
                icon: nil,
                byline: nil,
                isLargeTitle: true
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
                secondViewActive: true,
                icon: nil,
                byline: nil,
                isLargeTitle: false
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
                secondViewActive: true,
                icon: nil,
                byline: nil,
                isLargeTitle: false
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
                secondViewActive: true,
                icon: nil,
                byline: nil,
                isLargeTitle: false
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
                secondViewActive: true,
                icon: nil,
                byline: nil,
                isLargeTitle: false
            ),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }

    func testIcon_iPhoneX() {
        assertSnapshots(
            matching: TestContainer(
                backButtonColor: .semantic.primary,
                secondViewActive: false,
                icon: Icon.placeholder,
                byline: nil,
                isLargeTitle: false
            ),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )

        assertSnapshots(
            matching: TestContainer(
                backButtonColor: .semantic.primary,
                secondViewActive: true,
                icon: Icon.placeholder,
                byline: nil,
                isLargeTitle: false
            ),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }

    func testByline_iPhoneX() {
        assertSnapshots(
            matching: TestContainer(
                backButtonColor: .semantic.primary,
                secondViewActive: false,
                icon: nil,
                byline: "Byline",
                isLargeTitle: false
            ),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )

        assertSnapshots(
            matching: TestContainer(
                backButtonColor: .semantic.primary,
                secondViewActive: true,
                icon: nil,
                byline: "Byline",
                isLargeTitle: false
            ),
            as: [
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhoneX), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }
}
