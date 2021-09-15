// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTourUI
import SnapshotTesting
import XCTest

class TourViewTests: XCTestCase {

    func testTourView() {
        let view = TourView()
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone8)))

        let brokerageView = TourView.Carousel.brokerage.makeView()
        assertSnapshot(matching: brokerageView, as: .image(layout: .device(config: .iPhone8)))

        let earnView = TourView.Carousel.earn.makeView()
        assertSnapshot(matching: earnView, as: .image(layout: .device(config: .iPhone8)))

        let keysView = TourView.Carousel.keys.makeView()
        assertSnapshot(matching: keysView, as: .image(layout: .device(config: .iPhone8)))

        let pricesView = TourView.Carousel.prices.makeView()
        assertSnapshot(matching: pricesView, as: .image(layout: .device(config: .iPhone8)))
    }
}
