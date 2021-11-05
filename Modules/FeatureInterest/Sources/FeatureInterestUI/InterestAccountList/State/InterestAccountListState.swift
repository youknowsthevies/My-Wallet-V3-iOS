// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import FeatureInterestDomain
import PlatformKit
import SwiftUI

struct InterestAccountListState: Equatable, NavigationState {

    var isLoading: Bool {
        loadingStatus.isLoading
    }

    var loadingTitle: String {
        loadingStatus.title
    }

    var route: RouteIntent<InterestAccountListRoute>?
    var interestTransactionState: InterestTransactionState?
    var interestAccountOverviews: [InterestAccountOverview] = []
    var interestAccountDetails: IdentifiedArrayOf<InterestAccountDetails> = []
    var interestNoEligibleWalletsState: InterestNoEligibleWalletsState?
    var interestAccountDetailsState: InterestAccountDetailsState?
    var isKYCVerified: Bool = false
    var buyCryptoCurrency: CryptoCurrency?
    var loadingStatus: InterestAccountLoadingStatus
}
