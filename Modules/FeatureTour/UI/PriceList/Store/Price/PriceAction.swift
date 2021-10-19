// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum PriceAction: Equatable {
    case currencyDidLoad
    case priceValuesDidLoad(price: String, delta: Double)
    case none
}
