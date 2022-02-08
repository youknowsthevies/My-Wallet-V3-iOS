// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import MoneyKit

extension AnalyticsEvents.New {

    enum TradingCurrency: AnalyticsEvent {

        case fiatCurrencySelected(currency: String)

        var type: AnalyticsEventType {
            .nabu
        }
    }
}

extension Reducer where Action == TradingCurrency.Action, Environment == TradingCurrency.Environment {

    func analytics() -> Reducer<State, Action, Environment> {
        combined(
            with: Reducer { _, action, environment in
                switch action {
                case .didSelect(let currency):
                    return .fireAndForget {
                        environment.analyticsRecorder.record(
                            event: AnalyticsEvents.New.TradingCurrency.fiatCurrencySelected(currency: currency.code)
                        )
                    }

                default:
                    return .none
                }
            }
        )
    }
}
