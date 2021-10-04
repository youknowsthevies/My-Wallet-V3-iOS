// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import FeatureAuthenticationDomain

public enum ResetAccountWarningAction: Equatable {
    case onDisappear
    case retryButtonTapped
    case continueResetButtonTapped
}

struct ResetAccountWarningState: Equatable {}

struct ResetAccountWarningEnvironment {
    let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI) {
        self.analyticsRecorder = analyticsRecorder
    }
}

let resetAccountWarningReducer = Reducer<
    ResetAccountWarningState,
    ResetAccountWarningAction,
    ResetAccountWarningEnvironment
> { _, action, environment in
    switch action {
    case .onDisappear:
        environment.analyticsRecorder.record(
            event: .resetAccountCancelled
        )
        return .none
    case .retryButtonTapped:
        return .none
    case .continueResetButtonTapped:
        return .none
    }
}
