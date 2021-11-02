// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureInterestDomain
import PlatformKit

typealias InterestAccountDetailsReducer = Reducer<
    InterestAccountDetailsState,
    InterestAccountDetailsAction,
    InterestAccountDetailsEnvironment
>

let interestAccountDetailsReducer = InterestAccountDetailsReducer { state, action, environment in
    switch action {
    case .loadInterestAccountBalanceInfo:
        let priceService = environment.priceService
        let overview = state.interestAccountOverview
        let balance = overview.balance
        let currency = overview.currency
        return environment
            .fiatCurrencyService
            .fiatCurrencyPublisher
            .flatMap { [priceService] fiatCurrency -> AnyPublisher<PriceQuoteAtTime, Error> in
                priceService
                    .price(
                        of: currency,
                        in: fiatCurrency
                    )
                    .eraseError()
            }
            .map(\.moneyValue)
            .map { moneyValue -> MoneyValue in
                balance.convert(using: moneyValue)
            }
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                switch result {
                case .success(let amount):
                    return .interestAccountFiatBalanceFetched(amount)
                case .failure:
                    return .interestAccountFiatBalanceFetchFailed
                }
            }
    case .interestAccountFiatBalanceFetchFailed:
        // TODO: Improve this
        state.interestAccountBalanceSummary = .init(
            currency: state.interestAccountOverview.currency,
            cryptoBalance: state.interestAccountOverview.balance.displayString,
            fiatBalance: "Unknown"
        )
        return .none
    case .interestAccountFiatBalanceFetched(let moneyValue):
        state.interestAccountBalanceSummary = .init(
            currency: state.interestAccountOverview.currency,
            cryptoBalance: state.interestAccountOverview.balance.displayString,
            fiatBalance: moneyValue.displayString
        )
        return .none
    case .interestTransferTapped:
        state.interestAccountActionSelection = .init(
            currency: state.interestAccountOverview.currency,
            action: .interestTransfer
        )
        return Effect(value: .dismissInterestDetailsScreen)
    case .interestWithdrawTapped:
        state.interestAccountActionSelection = .init(
            currency: state.interestAccountOverview.currency,
            action: .interestWithdraw
        )
        return Effect(value: .dismissInterestDetailsScreen)
    case .loadCryptoInterestAccount,
         .startInterestTransfer,
         .startInterestWithdraw,
         .closeButtonTapped,
         .interestAccountDescriptorTapped,
         .dismissInterestDetailsScreen:
        return .none
    }
}
