// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ComponentLibrary
import SnapshotTesting
import XCTest

final class LineGraphTests: XCTestCase {
    // swiftlint:disable:next line_length
    private let oneYearData: [Double] = [19164.48, 19276.59, 19439.75, 21379.48, 22847.46, 23150.79, 23869.92, 23490.58, 22745.48, 23824.99, 23253.37, 23715.53, 24693.58, 26443.21, 26246.58, 27036.69, 27376.37, 28856.59, 28982.56, 29393.75, 32195.46, 33000.78, 32035.03, 34046.67, 36860.41, 39486.04, 40670.25, 40240.72, 38240.09, 35544.94, 34011.82, 37393.13, 39158.47, 36828.52, 36065.2, 35793.01, 36632.35, 36020.13, 35538.98, 30797.88, 33002.38, 32099.74, 32276.84, 32243.26, 32541.8, 30419.17, 33403.17, 34314.26, 34318.1, 33136.46, 33522.9, 35529.66, 37676.25, 37002.09, 38278.61, 39323.26, 38928.1, 46364.3, 46589.58, 44878.17, 48013.38, 47471.4, 47185.19, 48720.37, 47951.85, 49160.1, 52118.23, 51608.15, 55916.5, 56001.2, 57487.86, 54123.4, 48880.43, 50624.84, 46800.42, 46340.31, 46155.87, 45113.92, 49618.43, 48356.04, 50477.7, 48448.91, 48861.38, 48881.59, 51169.7, 52299.33, 54881.52, 55997.23, 57764.0, 57253.28, 61258.73, 59133.47, 55754.72, 56872.38, 58913.0, 57665.9, 58075.1, 58085.8, 57411.17, 54204.96, 54477.46, 52508.23, 51415.92, 55074.47, 55863.93, 55783.71, 57627.67, 58730.13, 58735.25, 58736.92, 59031.32, 57076.49, 58206.55, 59054.1, 58020.46, 55947.27, 58048.59, 58102.58, 59774.0, 59964.87, 59834.74, 63554.44, 62969.12, 63252.63, 61455.98, 60087.09, 56251.48, 55703.14, 56507.91, 53808.8, 51731.71, 51153.13, 50110.53, 49075.58, 54056.64, 55071.46, 54884.1, 53584.15, 57796.62, 57857.5, 56610.46, 57213.33, 53241.72, 57473.23, 56428.16, 57380.27, 58928.81, 58280.73, 55883.5, 56750.0, 49007.09, 49702.27, 49922.52, 46736.58, 46441.64, 43596.24, 42912.19, 36964.27, 40784.32, 37280.35, 37528.3, 34754.54, 38728.59, 38410.5, 39266.04, 38445.29, 35689.62, 34647.67, 35684.59, 37310.54, 36662.64, 37585.24, 39188.59, 36885.51, 35530.38, 35816.17, 33514.87, 33450.19, 37338.36, 36704.57, 37313.18, 35494.9, 39066.82, 40525.8, 40188.56, 38324.87, 38068.04, 35729.82, 35524.17, 35592.35, 31686.55, 32447.59, 33674.66, 34639.38, 31640.58, 32160.91, 34644.45, 34456.67, 35847.7, 35047.36, 33536.88, 33856.86, 34688.98, 35309.3, 33747.97, 34211.01, 33839.04, 32877.41, 33818.52, 33515.57, 34227.64, 33158.25, 32686.56, 32814.61, 31738.59, 31421.25, 31520.66, 31783.49, 30815.94, 29790.24, 32118.06, 32297.89, 33581.63, 34279.34, 35365.2, 37318.14, 39405.95, 40002.53, 40005.93, 42214.15, 41659.06, 40000.46, 39193.94, 38138.0, 39750.14, 40882.0, 42825.95, 44634.13, 43816.14, 46333.46, 45608.37, 45611.46, 44417.78, 47833.98, 47112.19, 47056.41, 45982.55, 44648.57, 44777.86, 46734.65, 49327.75, 48932.02, 49335.68, 49523.5, 47744.58, 48972.09, 46962.8, 49056.86, 48897.65, 48806.78, 47074.77, 47155.87, 48862.76, 49329.01, 50035.33, 49947.38, 51769.06, 52677.4, 46809.17, 46078.38, 46368.69, 44847.48, 45144.79, 46059.12, 44968.76, 47072.12, 48167.85, 47785.26, 47263.6, 48259.45, 47249.38, 42901.56, 40619.27, 43604.76, 44888.96, 42815.56, 42742.01, 43182.63, 42238.2, 41011.16, 41522.38, 43757.81, 48140.11, 47727.1, 48205.72, 49143.95, 51505.83, 55343.76, 53801.1, 53867.3, 55122.59, 54625.74, 57452.01, 56242.94, 57406.69, 57397.74, 61641.17, 60948.78, 61546.21, 61971.59, 64287.64, 66063.56, 62354.86, 60697.06, 61277.28, 60884.18, 63070.54, 60345.17, 58538.49, 60587.09, 62249.18, 61731.29, 61373.44, 61029.5, 63241.11, 62954.86, 61441.83, 61072.32, 61516.31, 63293.22, 67562.17, 66954.11, 64976.73, 64838.81, 64254.67, 64420.94, 65468.75, 63584.25, 60172.26, 60381.35, 56921.34, 58133.02, 59777.98, 58755.9, 56301.52, 57578.22, 57187.54, 58935.45, 53588.21, 54801.15, 57292.28, 57828.45, 57025.79, 57229.76, 56508.48, 53713.84, 49253.86, 49380.43, 50564.63, 50645.41, 50511.12, 47659.68, 47137.46]

    func testPointsInRectPerformance() throws {
        try XCTSkipIf(true) // Disable performance testing on CI

        // 0.001s on Xcode 12, iPhone 8 simulator, MacBookPro16,1

        let data: [Double] = (0..<1000).map { _ in Double.random(in: 0..<100) }
        measure {
            _ = data.points(in: CGSize(width: 400, height: 400))
        }
    }

    func testCubicSmoothingPerformance() throws {
        try XCTSkipIf(true) // Disable performance testing on CI

        // 0.002s on Xcode 12, iPhone 8 simulator, MacBookPro16,1

        let data: [Double] = (0..<1000).map { _ in Double.random(in: 0..<100) }
        let points = data.points(in: CGSize(width: 400, height: 400))
        measure {
            _ = cubicPath(from: points)
        }
    }

    func testUnselected() {
        let view = LineGraph(
            selectedIndex: .constant(nil),
            selectionTitle: nil,
            smoothingChunkSize: 7,
            showsCurrentDot: false,
            data: oneYearData
        )
        .frame(width: 375)
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(layoutDirection: .rightToLeft))
            ],
            record: false
        )
    }

    func testSelected() {
        let view = LineGraph(
            selectedIndex: .constant(300),
            selectionTitle: "Nov 12, 2021",
            smoothingChunkSize: 7,
            showsCurrentDot: false,
            data: oneYearData
        )
        .frame(width: 375)
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(layoutDirection: .rightToLeft))
            ],
            record: false
        )
    }

    func testLiveUnselected() {
        let view = LineGraph(
            selectedIndex: .constant(nil),
            selectionTitle: nil,
            smoothingChunkSize: 7,
            showsCurrentDot: true,
            data: Array(oneYearData[0..<60])
        )
        .frame(width: 375)
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(layoutDirection: .rightToLeft))
            ],
            record: false
        )
    }

    func testLiveSelected() {
        let view = LineGraph(
            selectedIndex: .constant(50),
            selectionTitle: "Nov 12, 2021",
            smoothingChunkSize: 7,
            showsCurrentDot: true,
            data: Array(oneYearData[0..<60])
        )
        .frame(width: 375)
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(layoutDirection: .rightToLeft))
            ],
            record: false
        )
    }

    func testTitleTrailingEdgeOffset() {
        let view = LineGraph(
            selectedIndex: .constant(oneYearData.count - 5),
            selectionTitle: "Nov 12, 2021",
            smoothingChunkSize: 7,
            showsCurrentDot: false,
            data: oneYearData
        )
        .frame(width: 375)
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(layoutDirection: .rightToLeft))
            ]
        )
    }

    func testTitleLeadingEdgeOffset() {
        let view = LineGraph(
            selectedIndex: .constant(5),
            selectionTitle: "Nov 12, 2021",
            smoothingChunkSize: 7,
            showsCurrentDot: false,
            data: oneYearData
        )
        .frame(width: 375)
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(layoutDirection: .rightToLeft))
            ]
        )
    }

    func testLiveTitleTrailingEdgeOffset() {
        let view = LineGraph(
            selectedIndex: .constant(oneYearData.count - 5),
            selectionTitle: "Nov 12, 2021",
            smoothingChunkSize: 7,
            showsCurrentDot: true,
            data: oneYearData
        )
        .frame(width: 375)
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(layoutDirection: .rightToLeft))
            ]
        )
    }
}
