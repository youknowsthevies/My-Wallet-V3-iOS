// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

struct InterestAccountLoadingStatus: Equatable {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.Overview

    var isLoading: Bool = false
    var title: String

    static var fetchingAccountStatus: InterestAccountLoadingStatus {
        .init(isLoading: true, title: LocalizationId.fetchingAccountStatus)
    }

    static var loading: InterestAccountLoadingStatus {
        .init(isLoading: true, title: LocalizationId.loading)
    }

    static var fetchingRewardsAccounts: InterestAccountLoadingStatus {
        .init(isLoading: true, title: LocalizationId.fetchingRewardsAccounts)
    }

    static var loaded: InterestAccountLoadingStatus {
        .init(title: "")
    }
}
