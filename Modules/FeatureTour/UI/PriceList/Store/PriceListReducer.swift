// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

let priceListReducer = Reducer<PriceListState, PriceListAction, PriceListEnvironment> { state, action, _ in
    switch action {
    case .price(id: let id, action: let action):
        return .none
    case .listDidScroll(let offset):
        state.onTop = offset > -10
        return .none
    case .none:
        return .none
    }
}
