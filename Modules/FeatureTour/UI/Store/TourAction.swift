// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

enum TourAction {
    case createAccount
    case restore
    case logIn
    case price(id: Price.ID, action: PriceAction)
    case priceListDidScroll(offset: CGFloat)
    case loadPrices
    case none
}
