// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import FeatureInterestDomain
import PlatformKit

enum InterestAccountListAction: Equatable, NavigationAction {
    case didReceiveInterestAccountResponse(Result<[InterestAccountOverview], InterestAccountOverviewError>)
    case dismissLoadingInterestAccountsAlert
    case loadInterestAccounts
    case interestAccountDetails(InterestAccountDetailsAction)
    case interestTransactionStateFetched(InterestTransactionState)
    case interestAccountButtonTapped(InterestAccountOverview.ID, InterestAccountListItemAction)
    case route(RouteIntent<InterestAccountListRoute>?)
}
