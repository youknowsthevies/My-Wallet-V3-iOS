// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import KYCKit

/// The `master` `State` for the Email Verification Flow
struct EmailVerificationState: Equatable {

    enum FlowStep {
        case loadingVerificationState
        case verifyEmailPrompt
        case emailVerificationHelp
        case editEmailAddress
        case emailVerifiedPrompt
        case verificationCheckFailed
    }

    var flowStep: FlowStep

    var verifyEmail: VerifyEmailState
    var emailVerificationHelp: EmailVerificationHelpState
    var editEmailAddress: EditEmailState
    var emailVerified: EmailVerifiedState

    var emailVerificationFailedAlert: AlertState<EmailVerificationAction>?

    init(emailAddress: String) {
        verifyEmail = VerifyEmailState(emailAddress: emailAddress)
        editEmailAddress = EditEmailState(emailAddress: emailAddress)
        emailVerificationHelp = EmailVerificationHelpState(emailAddress: emailAddress)
        emailVerified = EmailVerifiedState()
        flowStep = .verifyEmailPrompt
    }
}

/// The `master` `Action`type  for the Email Verification Flow
enum EmailVerificationAction: Equatable {
    case closeButtonTapped
    case didEnterForeground
    case didReceiveEmailVerficationResponse(Result<EmailVerificationResponse, EmailVerificationCheckError>)
    case dismissEmailVerificationFailedAlert
    case loadVerificationState
    case presentStep(EmailVerificationState.FlowStep)
    case verifyEmail(VerifyEmailAction)
    case emailVerified(EmailVerifiedAction)
    case editEmailAddress(EditEmailAction)
    case emailVerificationHelp(EmailVerificationHelpAction)
}

/// The `master` `Environment` for the Email Verification Flow
struct EmailVerificationEnvironment {

    let emailVerificationService: EmailVerificationServiceAPI
    let flowCompletionCallback: ((FlowResult) -> Void)?
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let openMailApp: () -> Effect<Bool, Never>

    init(
        emailVerificationService: EmailVerificationServiceAPI,
        flowCompletionCallback: ((FlowResult) -> Void)?,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        openMailApp: @escaping () -> Effect<Bool, Never>
    ) {
        self.emailVerificationService = emailVerificationService
        self.flowCompletionCallback = flowCompletionCallback
        self.mainQueue = mainQueue
        self.openMailApp = openMailApp
    }
}

/// The `master` `Reducer` for the Email Verification Flow
let emailVerificationReducer = Reducer.combine(
    verifyEmailReducer.pullback(
        state: \EmailVerificationState.verifyEmail,
        action: /EmailVerificationAction.verifyEmail,
        environment: {
            VerifyEmailEnvironment(
                openMailApp: $0.openMailApp
            )
        }
    ),
    emailVerifiedReducer.pullback(
        state: \EmailVerificationState.emailVerified,
        action: /EmailVerificationAction.emailVerified,
        environment: { _ in
            EmailVerifiedEnvironment()
        }
    ),
    emailVerificationHelpReducer.pullback(
        state: \EmailVerificationState.emailVerificationHelp,
        action: /EmailVerificationAction.emailVerificationHelp,
        environment: {
            EmailVerificationHelpEnvironment(
                emailVerificationService: $0.emailVerificationService,
                mainQueue: $0.mainQueue
            )
        }
    ),
    editEmailReducer.pullback(
        state: \EmailVerificationState.editEmailAddress,
        action: /EmailVerificationAction.editEmailAddress,
        environment: {
            EditEmailEnvironment(
                emailVerificationService: $0.emailVerificationService,
                mainQueue: $0.mainQueue
            )
        }
    ),
    Reducer<EmailVerificationState, EmailVerificationAction, EmailVerificationEnvironment> { state, action, environment in
        switch action {
        case .closeButtonTapped:
            environment.flowCompletionCallback?(.abandoned)
            return .none

        case .didEnterForeground:
            return Effect(value: .loadVerificationState)

        case .didReceiveEmailVerficationResponse(let response):
            switch response {
            case .success(let object):
                return Effect(value: .presentStep(object.status == .verified ? .emailVerifiedPrompt : .verifyEmailPrompt))

            case .failure(let error):
                state.emailVerificationFailedAlert = .init(
                    title: TextState(L10n.GenericError.title),
                    message: TextState(L10n.EmailVerification.couldNotLoadVerificationStatusAlertMessage),
                    primaryButton: .default(
                        TextState(L10n.GenericError.retryButtonTitle),
                        send: .loadVerificationState
                    ),
                    secondaryButton: .cancel()
                )
                return Effect(value: .presentStep(.verificationCheckFailed))
            }

        case .loadVerificationState:
            return .merge(
                .init(value: .presentStep(.loadingVerificationState)),
                environment.emailVerificationService.checkEmailVerificationStatus()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result in
                        .didReceiveEmailVerficationResponse(result)
                    }
            )

        case .dismissEmailVerificationFailedAlert:
            state.emailVerificationFailedAlert = nil
            return .init(value: .presentStep(.verifyEmailPrompt))

        case .presentStep(let flowStep):
            state.flowStep = flowStep
            return .none

        case .verifyEmail(let subaction):
            switch subaction {
            case .tapGetEmailNotReceivedHelp:
                return .init(value: .presentStep(.emailVerificationHelp))

            default:
                return .none
            }

        case .emailVerified(let subaction):
            switch subaction {
            case .acknowledgeEmailVerification:
                environment.flowCompletionCallback?(.completed)
                return .none
            }

        case .emailVerificationHelp(let subaction):
            switch subaction {
            case .editEmailAddress:
                return .init(value: .presentStep(.editEmailAddress))

            case .didReceiveEmailSendingResponse(let response):
                switch response {
                case .success:
                    return .init(value: .presentStep(.verifyEmailPrompt))

                default:
                    break
                }

            default:
                break
            }
            return .none

        case .editEmailAddress(let subaction):
            switch subaction {
            case .didReceiveSaveResponse(let response):
                switch response {
                case .success:
                    // updating email address for the flow so we are certain that (1.) the user wants to confirm and (2.) the change is reflected on the backend
                    state.verifyEmail.emailAddress = state.editEmailAddress.emailAddress
                    state.emailVerificationHelp.emailAddress = state.editEmailAddress.emailAddress
                    return .init(value: .presentStep(.verifyEmailPrompt))

                default:
                    break
                }

            default:
                break
            }
            return .none
        }
    }
)
