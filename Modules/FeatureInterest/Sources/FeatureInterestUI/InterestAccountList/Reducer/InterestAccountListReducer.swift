// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureInterestDomain
import PlatformKit
import ToolKit

struct TransactionFetchIdentifier: Hashable {}

typealias InterestAccountListReducer = Reducer<
    InterestAccountListState,
    InterestAccountListAction,
    InterestAccountSelectionEnvironment
>

let interestAccountListReducer = Reducer.combine(
    interestAccountDetailsReducer
        .optional()
        .pullback(
            state: \.interestAccountDetailsState,
            action: /InterestAccountListAction.interestAccountDetails,
            environment: {
                InterestAccountDetailsEnvironment(
                    fiatCurrencyService: $0.fiatCurrencyService,
                    priceService: $0.priceService,
                    mainQueue: $0.mainQueue
                )
            }
        ),
    Reducer<
        InterestAccountListState,
        InterestAccountListAction,
        InterestAccountSelectionEnvironment
    > { state, action, environment in
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
                state.interestAccountOverviews = accountOverviews
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

        case .interestAccountButtonTapped(let selected, let action):
            switch action {
            case .viewInterestButtonTapped:
                guard let overview = state
                    .interestAccountOverviews
                    .first(where: { $0.id == selected.identity })
                else {
                    fatalError("Expected an InterestAccountOverview")
                }

                state.interestAccountDetailsState = .init(interestAccountOverview: overview)
                return .enter(into: .details)
            case .earnInterestButtonTapped:
                // TODO:
                return .none
            }
        case .interestAccountDetails:
            return .none
        case .route(let route):
            state.route = route
            return .none
        case .interestTransactionStateFetched(let transactionState):
            state.interestTransactionState = transactionState
            let isTransfer = transactionState.action == .interestTransfer
            return .merge(
                .cancel(id: TransactionFetchIdentifier()),
                Effect(
                    value: .interestAccountDetails(
                        isTransfer ? .startInterestTransfer : .startInterestWithdraw
                    )
                )
            )
        }
    },
    interestReducerCore
)

let interestReducerCore = Reducer<
    InterestAccountListState,
    InterestAccountListAction,
    InterestAccountSelectionEnvironment
> { _, action, environment in
    switch action {
    case .interestAccountDetails(.dismissInterestDetailsScreen):
        return .enter(into: nil)
    case .interestAccountDetails(
        .loadCryptoInterestAccount(
            isTransfer: let isTransfer,
            let currency
        )
    ):
        return .merge(
            environment
                .blockchainAccountRepository
                .accountWithCurrencyType(
                    currency,
                    accountType: .custodial(.savings)
                )
                .compactMap { $0 as? CryptoInterestAccount }
                .map { account in
                    InterestTransactionState(
                        account: account,
                        action: isTransfer ? .interestTransfer : .interestWithdraw
                    )
                }
                .catchToEffect()
                .cancellable(id: TransactionFetchIdentifier())
                .map { transactionState in
                    guard let value = transactionState.successData else {
                        unimplemented()
                    }
                    return value
                }
                .map { transactionState -> InterestAccountListAction in
                    .interestTransactionStateFetched(transactionState)
                }
        )
    case .interestAccountDetails(.startInterestWithdraw):
        return .merge(
            .enter(into: nil),
            .sheet(into: .transaction)
        )
    case .interestAccountDetails(.startInterestTransfer):
        return .merge(
            .enter(into: nil),
            .sheet(into: .transaction)
        )
    default:
        return .none
    }
}
