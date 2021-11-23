// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureKYCUI
import SnapshotTesting
import XCTest

final class LimitedTradeFeatureCellTests: XCTestCase {

    func test_basic_info_for_all_features() throws {
        for feature in exampleFeatures {
            let view = LimitedTradeFeatureCell(feature: feature)
                .frame(width: 320)
                .fixedSize()

            assertSnapshots(
                matching: view,
                as: [
                    .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                    .image(traits: UITraitCollection(userInterfaceStyle: .dark))
                ]
            )
        }
    }
}
