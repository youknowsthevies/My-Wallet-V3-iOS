// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import PlatformKit
import SwiftUI

let tourReducer = Reducer<TourState, TourAction, TourEnvironment>.combine(
    priceReducer.forEach(
        state: \TourState.items,
        action: /TourAction.price(id:action:),
        environment: { _ in PriceEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .createAccount:
            environment.createAccountAction()
            return .none
        case .restore:
            environment.restoreAction()
            return .none
        case .logIn:
            environment.logInAction()
            return .none
        case .price(id: let id, action: let action):
            return .none
        case .priceListDidScroll(let offset):
            state.scrollOffset = offset
            return .none
        case .loadPrices:
            let currencies = environment.enabledCurrenciesService.allEnabledCryptoCurrencies
            state.items = IdentifiedArray(uniqueElements: currencies.map { Price(currency: $0) })
            let effects = state.items.map {
                Effect<TourAction, Never>(value: TourAction.price(id: $0.id, action: .currencyDidLoad))
            }
            return .merge(effects)
        case .none:
            return .none
        }
    }
)
