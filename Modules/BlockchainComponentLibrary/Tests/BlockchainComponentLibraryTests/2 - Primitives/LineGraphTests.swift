// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

final class LineGraphTests: XCTestCase {

    private let data: [Double] = stride(
        from: .pi,
        to: 8 * .pi,
        by: .pi / 180
    )
    .map { sin($0) + 1 }

    let record = false

    func test_sliding_averages_performance() throws {
        try XCTSkipIf(true) // Disable performance testing on CI

        // 0.001s on Xcode 12, iPhone 8 simulator, MacBookPro16,1

        let data: [Double] = (0..<1000).map { _ in Double.random(in: 0..<100) }
        measure {
            _ = data.slidingAverages(radius: 3, prefixAndSuffix: .none)
        }
    }

    func testUnselected() throws {
        try XCTSkipIf(true)
        let view = LineGraph(
            selection: .constant(nil),
            selectionTitle: { i, _ in Text("\(i)") },
            minimumTitle: { i, _ in Text("\(i)") },
            maximumTitle: { i, _ in Text("\(i)") },
            data: data
        )
        .frame(width: 375, height: 300)

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: record
        )
    }

    func testSelected() throws {
        try XCTSkipIf(true)
        let view = LineGraph(
            selection: .constant(300),
            selectionTitle: { _, _ in Text("Nov 12, 2021") },
            minimumTitle: { i, _ in Text("\(i)") },
            maximumTitle: { i, _ in Text("\(i)") },
            data: data
        )
        .frame(width: 375, height: 300)

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: record
        )
    }

    func testLiveUnselected() throws {
        try XCTSkipIf(true)
        let view = LineGraph(
            selection: .constant(nil),
            selectionTitle: { i, _ in Text("\(i)") },
            minimumTitle: { i, _ in Text("\(i)") },
            maximumTitle: { i, _ in Text("\(i)") },
            data: Array(data[0..<60]),
            isLive: true
        )
        .frame(width: 375, height: 300)

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: record
        )
    }

    func testLiveSelected() throws {
        try XCTSkipIf(true)
        let view = LineGraph(
            selection: .constant(50),
            selectionTitle: { i, _ in Text("\(i)") },
            minimumTitle: { i, _ in Text("\(i)") },
            maximumTitle: { i, _ in Text("\(i)") },
            data: Array(data[0..<60]),
            isLive: true
        )
        .frame(width: 375, height: 300)

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: record
        )
    }

    func testTitleTrailingEdgeOffset() throws {
        try XCTSkipIf(true)
        let view = LineGraph(
            selection: .constant(data.count - 5),
            selectionTitle: { _, _ in Text("Nov 12, 2021") },
            minimumTitle: { i, _ in Text("\(i)") },
            maximumTitle: { i, _ in Text("\(i)") },
            data: data
        )
        .frame(width: 375, height: 300)

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light))
            ],
            record: record
        )
    }

    func testTitleLeadingEdgeOffset() throws {
        try XCTSkipIf(true)
        let view = LineGraph(
            selection: .constant(5),
            selectionTitle: { _, _ in Text("Nov 12, 2021") },
            minimumTitle: { i, _ in Text("\(i)") },
            maximumTitle: { i, _ in Text("\(i)") },
            data: data
        )
        .frame(width: 375, height: 300)

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light))
            ],
            record: record
        )
    }

    func testLiveTitleTrailingEdgeOffset() throws {
        try XCTSkipIf(true)
        let view = LineGraph(
            selection: .constant(data.count - 5),
            selectionTitle: { _, _ in Text("Nov 12, 2021") },
            minimumTitle: { i, _ in Text("\(i)") },
            maximumTitle: { i, _ in Text("\(i)") },
            data: data
        )
        .frame(width: 375, height: 300)

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light))
            ],
            record: record
        )
    }
}
