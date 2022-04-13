// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import FeatureFormDomain
import Localization
import NabuNetworkError
import ToolKit

enum AccountUsage {

    typealias State = LoadingState<AccountUsage.Form.State, FailureState<AccountUsage.Action>>
    private typealias Events = AnalyticsEvents.New.KYC

    enum Action: Equatable {
        case onAppear
        case onComplete
        case loadForm
        case formDidLoad(Result<[FormQuestion], NabuNetworkError>)
        case form(AccountUsage.Form.Action)
    }

    struct Environment {
        let onComplete: () -> Void
        let loadForm: () -> AnyPublisher<[FormQuestion], NabuNetworkError>
        let submitForm: ([FormQuestion]) -> AnyPublisher<Void, NabuNetworkError>
        let analyticsRecorder: AnalyticsEventRecorderAPI
        let mainQueue: AnySchedulerOf<DispatchQueue> = .main
    }

    static let reducer = Reducer.combine(
        Reducer<State, Action, Environment> { state, action, environment in
            switch action {
            case .onAppear:
                environment.analyticsRecorder.record(event: Events.accountInfoScreenViewed)
                return Effect(value: .loadForm)

            case .onComplete:
                return .fireAndForget(environment.onComplete)

            case .loadForm:
                state = .loading
                return environment.loadForm()
                    .catchToEffect()
                    .map(Action.formDidLoad)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()

            case .formDidLoad(let result):
                switch result {
                case .success(let form):
                    state = .success(AccountUsage.Form.State(questions: form))
                case .failure(let error):
                    // If we receive a 204, the user doesn't have to complete the form, so we can just complete
                    if case .communicatorError(let networkError) = error {
                        if case .payloadError(let payloadError) = networkError {
                            if case .emptyData = payloadError {
                                state = .success(AccountUsage.Form.State(questions: []))
                                return Effect(value: .onComplete)
                            }
                        }
                    }

                    // Otherwise, handle the failure
                    state = .failure(
                        FailureState(
                            title: LocalizationConstants.NewKYC.GenericError.title,
                            message: String(describing: error),
                            buttons: [
                                .primary(
                                    title: LocalizationConstants.NewKYC.GenericError.retryButtonTitle,
                                    action: .loadForm
                                )
                            ]
                        )
                    )
                }
                return .none

            case .form(let action):
                switch action {
                case .submit:
                    return .fireAndForget {
                        environment.analyticsRecorder.record(event: Events.accountInfoSubmitted)
                    }

                case .onComplete:
                    return Effect(value: .onComplete)

                default:
                    return .none
                }
            }
        },
        AccountUsage.Form.reducer.pullback(
            state: /AccountUsage.State.success,
            action: /AccountUsage.Action.form,
            environment: {
                AccountUsage.Form.Environment(
                    submitForm: $0.submitForm,
                    mainQueue: $0.mainQueue
                )
            }
        )
    )
}

// MARK: SwiftUI Preview Helpers

extension AccountUsage.Environment {

    static let preview = AccountUsage.Environment(
        onComplete: {},
        loadForm: { .empty() },
        submitForm: { _ in .empty() },
        analyticsRecorder: NoOpAnalyticsRecorder()
    )
}
