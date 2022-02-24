// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

struct TourState: Equatable {

    enum Step: Hashable {
        case brokerage
        case earn
        case keys
        case prices
    }

    private let scrollEffectTransitionDistance: CGFloat = 300

    var items = IdentifiedArrayOf<Price>()
    var scrollOffset: CGFloat = 0
    var visibleStep: Step = .brokerage

    var gradientBackgroundOpacity: Double {
        switch scrollOffset {
        case _ where scrollOffset >= 0:
            return 1
        case _ where scrollOffset <= -scrollEffectTransitionDistance:
            return 0
        default:
            return 1 - Double(scrollOffset / -scrollEffectTransitionDistance)
        }
    }

    var priceListMaskStartYPoint: CGFloat {
        switch scrollOffset {
        case _ where scrollOffset >= 0:
            return 0
        case _ where scrollOffset <= -scrollEffectTransitionDistance:
            return 0.99
        default:
            return scrollOffset / -scrollEffectTransitionDistance
        }
    }
}
