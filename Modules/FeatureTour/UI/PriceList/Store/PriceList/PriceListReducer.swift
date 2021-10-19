// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import PlatformKit

let priceListReducer = Reducer<PriceListState, PriceListAction, PriceListEnvironment>.combine(
    priceReducer.forEach(
        state: \PriceListState.items,
        action: /PriceListAction.price(id:action:),
        environment: { _ in PriceEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .price(id: let id, action: let action):
            return .none
        case .listDidScroll(let offset):
            state.onTop = offset > -10
            return .none
        case .loadPrices:
            let currencies = environment.enabledCurrenciesService.allEnabledCryptoCurrencies
            state.items = IdentifiedArray(uniqueElements: currencies.map { Price(currency: $0) })
            let effects = state.items.map {
                Effect<PriceListAction, Never>(value: PriceListAction.price(id: $0.id, action: .currencyDidLoad))
            }
            return .merge(effects)
        case .none:
            return .none
        }
    }
)
