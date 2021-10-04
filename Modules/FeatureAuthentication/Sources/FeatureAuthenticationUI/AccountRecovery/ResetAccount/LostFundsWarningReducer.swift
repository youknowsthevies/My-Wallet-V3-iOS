// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import FeatureAuthenticationDomain

public enum LostFundsWarningAction: Equatable {
    case onDisappear
    case resetAccountButtonTapped
    case goBackButtonTapped
    case setResetPasswordScreenVisible(Bool)
    case resetPassword(ResetPasswordAction)
}

struct LostFundsWarningState: Equatable {
    var resetPasswordState: ResetPasswordState?
    var isResetPasswordScreenVisible: Bool = false
}

struct LostFundsWarningEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.mainQueue = mainQueue
        self.analyticsRecorder = analyticsRecorder
    }
}

let lostFundsWarningReducer = Reducer.combine(
    resetPasswordReducer
        .optional()
        .pullback(
            state: \LostFundsWarningState.resetPasswordState,
            action: /LostFundsWarningAction.resetPassword,
            environment: {
                ResetPasswordEnvironment(
                    mainQueue: $0.mainQueue
                )
            }
        ),
    Reducer<
        LostFundsWarningState,
        LostFundsWarningAction,
        LostFundsWarningEnvironment
    > { state, action, environment in
        switch action {
        case .onDisappear:
            environment.analyticsRecorder.record(
                event: .resetAccountCancelled
            )
            return .none
        case .goBackButtonTapped:
            return .none
        case .resetAccountButtonTapped:
            return Effect(value: .setResetPasswordScreenVisible(true))
        case .resetPassword:
            return .none
        case .setResetPasswordScreenVisible(let isVisible):
            state.isResetPasswordScreenVisible = isVisible
            if isVisible {
                state.resetPasswordState = .init()
            }
            return .none
        }
    }
)
