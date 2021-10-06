// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureInterestDomain
import PlatformKit

typealias InterestAccountListReducer = Reducer<
    InterestAccountListState,
    InterestAccountListAction,
    InterestAccountSelectionEnvironment
>

let interestAccountListReducer = InterestAccountListReducer { state, action, environment in
    switch action {
    case .didReceiveInterestAccountResponse(let response):
        switch response {
        case .success(let accountOverviews):
            let details: [InterestAccountDetails] = accountOverviews.map { accountOverview in
                .init(
                    ineligibilityReason: accountOverview.ineligibilityReason,
                    currency: accountOverview.currency,
                    balance: accountOverview.balance,
                    interestEarned: accountOverview.totalEarned,
                    rate: accountOverview.interestAccountRate.rate
                )
            }
            state.interestAccountDetails = .init(uniqueElements: details)
            state.loadingInterestAccountList = false
        case .failure(let error):
            break
        }
        return .none

    case .dismissLoadingInterestAccountsAlert:
        state.loadingErrorAlert = nil
        return .none

    case .loadInterestAccounts:
        state.loadingInterestAccountList = true
        return environment
            .fiatCurrencyService
            .fiatCurrencyPublisher
            .flatMap { [environment] fiatCurrency in
                environment
                    .accountOverviewRepository
                    .fetchInterestAccountOverviewListForFiatCurrency(fiatCurrency)
            }
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                .didReceiveInterestAccountResponse(result)
            }

    case .closeButtonTapped:
        return .none
    case .interestAccountButtonTapped(let selected, let action):
        switch action {
        case .viewInterestButtonTapped(let currencyType):
            return environment
                .accountRepository
                .accountWithCurrencyType(currencyType, accountType: .custodial(.savings))
                .mapError(InterestAccountOverviewError.accountRepositoryError)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result in
                    .showInterestAccountDetails(result)
                }

        case .earnInterestButtonTapped:
            // TODO:
            return .none
        }
    case .showInterestAccountDetails(let account):
        // TODO:
        return .none
    }
}
