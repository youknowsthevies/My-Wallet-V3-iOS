// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

struct PriceListState: Equatable {
    var items = IdentifiedArrayOf<Price>()
    var onTop = true
}
