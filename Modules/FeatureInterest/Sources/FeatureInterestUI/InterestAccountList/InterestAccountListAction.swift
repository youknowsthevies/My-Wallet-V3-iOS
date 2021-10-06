// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureInterestDomain
import PlatformKit

enum InterestAccountListAction: Equatable {
    case didReceiveInterestAccountResponse(Result<[InterestAccountOverview], InterestAccountOverviewError>)
    case dismissLoadingInterestAccountsAlert
    case loadInterestAccounts
    case closeButtonTapped
    case interestAccountButtonTapped(InterestAccountOverview.ID, InterestAccountListItemAction)
    case showInterestAccountDetails(Result<BlockchainAccount, InterestAccountOverviewError>)
}

extension InterestAccountListAction {
    static func == (
        lhs: InterestAccountListAction,
        rhs: InterestAccountListAction
    ) -> Bool {
        switch (lhs, rhs) {
        case (.didReceiveInterestAccountResponse(let left), .didReceiveInterestAccountResponse(let right)):
            return left == right
        case (.showInterestAccountDetails(let left), .showInterestAccountDetails(let right)):
            switch (left, right) {
            case (.success(let leftAccount), .success(let rightAccount)):
                return leftAccount.identifier == rightAccount.identifier
            case (.failure(let leftError), .failure(let rightError)):
                return leftError == rightError
            default:
                return false
            }
        case (
            .interestAccountButtonTapped(let leftId, let leftAction),
            .interestAccountButtonTapped(let rightId, let rightAction)
        ):
            return leftId == rightId &&
                leftAction == rightAction
        case (.closeButtonTapped, .closeButtonTapped),
             (.loadInterestAccounts, .loadInterestAccounts),
             (.dismissLoadingInterestAccountsAlert, .dismissLoadingInterestAccountsAlert):
            return true
        default:
            return false
        }
    }
}
