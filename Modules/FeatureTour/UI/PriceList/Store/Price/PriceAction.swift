// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum PriceAction: Equatable {
    case currencyDidAppear
    case currencyDidDisappear
    case priceValuesDidLoad(price: String, delta: Double)
    case none
}
