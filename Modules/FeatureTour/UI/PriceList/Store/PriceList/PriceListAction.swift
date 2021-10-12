// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

enum PriceListAction {
    case price(id: Price.ID, action: PriceAction)
    case listDidScroll(offset: CGFloat)
    case loadPrices
    case none
}
