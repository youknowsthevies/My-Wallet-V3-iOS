// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import KYCUIKit
import XCTest

final class EmailVerificationReducerTests: XCTestCase {

    fileprivate struct RecordedInvocations {
        var flowCompletionCallback: Int = 0
    }

    fileprivate struct StubbedResults {
        var canOpenMailApp: Bool = false
    }

    private var recordedInvocations: RecordedInvocations!
    private var stubbedResults: StubbedResults!

    private var testStore: TestStore<
        EmailVerificationState,
        EmailVerificationState,
        EmailVerificationAction,
        EmailVerificationAction,
        EmailVerificationEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        recordedInvocations = RecordedInvocations()
        stubbedResults = StubbedResults()
        resetTestStore()
    }

    override func tearDownWithError() throws {
        recordedInvocations = nil
        stubbedResults = nil
        testStore = nil
        try super.tearDownWithError()
    }

    // MARK: Root State Manipulation

    func test_substates_init() throws {
        let emailAddress = "test@example.com"
        let state = EmailVerificationState(emailAddress: emailAddress)
        XCTAssertEqual(state.verifyEmail.emailAddress, emailAddress)
        XCTAssertEqual(state.editEmailAddress.emailAddress, emailAddress)
        XCTAssertEqual(state.emailVerificationHelp.emailAddress, emailAddress)
    }

    func test_flowStep_startsAt_verifyEmail() throws {
        let state = EmailVerificationState(emailAddress: "test@example.com")
        XCTAssertEqual(state.flowStep, .verifyEmailPrompt)
    }

    func test_loads_verificationStatus_when_app_opened_unverified() throws {
        testStore.assert(
            .send(.didEnterForeground),
            .receive(.loadVerificationState),
            .receive(.presentStep(.loadingVerificationState)) {
                $0.flowStep = .loadingVerificationState
            },
            .receive(.didReceiveEmailVerficationResponse(.success(.unverified))),
            .receive(.presentStep(.verifyEmailPrompt)) {
                $0.flowStep = .verifyEmailPrompt
            }
        )
    }

    func test_loads_verificationStatus_when_app_opened_verified() throws {
        let mockService = testStore.environment.emailVerificationService as? MockEmailVerificationService
        mockService?.stubbedResults.checkEmailVerificationStatus = .just(.verified)
        testStore.assert(
            .send(.didEnterForeground),
            .receive(.loadVerificationState),
            .receive(.presentStep(.loadingVerificationState)) {
                $0.flowStep = .loadingVerificationState
            },
            .receive(.didReceiveEmailVerficationResponse(.success(.verified))),
            .receive(.presentStep(.emailVerifiedPrompt)) {
                $0.flowStep = .emailVerifiedPrompt
            }
        )
    }

    func test_loads_verificationStatus_when_app_opened_error() throws {
        let mockService = testStore.environment.emailVerificationService as? MockEmailVerificationService
        mockService?.stubbedResults.checkEmailVerificationStatus = .failure(.nabuError(.mockError))
        testStore.assert(
            .send(.didEnterForeground),
            .receive(.loadVerificationState),
            .receive(.presentStep(.loadingVerificationState)) {
                $0.flowStep = .loadingVerificationState
            },
            .receive(.didReceiveEmailVerficationResponse(.failure(.nabuError(.mockError)))) {
                $0.emailVerificationFailedAlert = AlertState(
                    title: TextState(L10n.GenericError.title),
                    message: TextState(L10n.EmailVerification.couldNotLoadVerificationStatusAlertMessage),
                    primaryButton: AlertState.Button.default(TextState(L10n.GenericError.retryButtonTitle), send: .loadVerificationState),
                    secondaryButton: AlertState.Button.cancel()
                )
            },
            .receive(.presentStep(.verificationCheckFailed)) {
                $0.flowStep = .verificationCheckFailed
            }
        )
    }

    func test_dismisses_verification_status_error() throws {
        testStore.assert(
            .send(.didReceiveEmailVerficationResponse(.failure(.nabuError(.mockError)))) {
                $0.emailVerificationFailedAlert = AlertState(
                    title: TextState(L10n.GenericError.title),
                    message: TextState(L10n.EmailVerification.couldNotLoadVerificationStatusAlertMessage),
                    primaryButton: AlertState.Button.default(TextState(L10n.GenericError.retryButtonTitle), send: .loadVerificationState),
                    secondaryButton: AlertState.Button.cancel()
                )
            },
            .receive(.presentStep(.verificationCheckFailed)) {
                $0.flowStep = .verificationCheckFailed
            },
            .send(.dismissEmailVerificationFailedAlert) {
                $0.emailVerificationFailedAlert = nil
            },
            .receive(.presentStep(.verifyEmailPrompt)) {
                $0.flowStep = .verifyEmailPrompt
            }
        )
    }

    // MARK: Verify Email State Manipulation

    func test_opens_inbox_failed() throws {
        testStore.assert(
            .send(.verifyEmail(.tapCheckInbox)),
            .receive(.verifyEmail(.presentCannotOpenMailAppAlert)) {
                $0.verifyEmail.cannotOpenMailAppAlert = AlertState(title: .init("Cannot Open Mail App"))
            },
            .send(.verifyEmail(.dismissCannotOpenMailAppAlert)) {
                $0.verifyEmail.cannotOpenMailAppAlert = nil
            }
        )
    }

    func test_opens_inbox_success() throws {
        stubbedResults.canOpenMailApp = true
        testStore.assert(
            .send(.verifyEmail(.tapCheckInbox)),
            .receive(.verifyEmail(.dismissCannotOpenMailAppAlert))
        )
    }

    func test_navigates_to_help() throws {
        testStore.assert(
            .send(.verifyEmail(.tapGetEmailNotReceivedHelp)),
            .receive(.presentStep(.emailVerificationHelp)) {
                $0.flowStep = .emailVerificationHelp
            }
        )
    }

    // MARK: Email Verified State Manipulation

    func test_email_verified_continue_calls_flowCompletion() throws {
        XCTAssertEqual(recordedInvocations.flowCompletionCallback, 0)
        testStore.assert(
            .send(.emailVerified(.acknowledgeEmailVerification)),
            .do {
                XCTAssertEqual(self.recordedInvocations.flowCompletionCallback, 1)
            }
        )
    }

    // MARK: Edit Email State Manipulation

    func test_edit_email_validates_email_on_appear_validEmail() throws {
        testStore.assert(
            .send(.editEmailAddress(.didAppear)) {
                $0.editEmailAddress.isEmailValid = true
            }
        )
    }

    func test_edit_email_validates_email_on_appear_invalidEmail() throws {
        resetTestStore(emailAddress: "test_example.com")
        testStore.assert(
            .send(.editEmailAddress(.didAppear)) {
                $0.editEmailAddress.isEmailValid = false
            }
        )
    }

    func test_edit_email_validates_email_on_appear_emptyEmail() throws {
        resetTestStore(emailAddress: "")
        testStore.assert(
            .send(.editEmailAddress(.didAppear)) {
                $0.editEmailAddress.isEmailValid = false
            }
        )
    }

    func test_edit_email_updates_and_validates_email_when_changed_to_validEmail() throws {
        testStore.assert(
            .send(.editEmailAddress(.didChangeEmailAddress("example@test.com"))) {
                $0.editEmailAddress.emailAddress = "example@test.com"
                $0.editEmailAddress.isEmailValid = true
            }
        )
    }

    func test_edit_email_updates_and_validates_email_when_changed_to_invalidEmail() throws {
        testStore.assert(
            .send(.editEmailAddress(.didChangeEmailAddress("example_test.com"))) {
                $0.editEmailAddress.emailAddress = "example_test.com"
                $0.editEmailAddress.isEmailValid = false
            }
        )
    }

    func test_edit_email_updates_and_validates_email_when_changed_to_emptyEmail() throws {
        testStore.assert(
            .send(.editEmailAddress(.didChangeEmailAddress(""))) {
                $0.editEmailAddress.emailAddress = ""
                $0.editEmailAddress.isEmailValid = false
            }
        )
    }

    func test_edit_email_save_success() throws {
        testStore.assert(
            .send(.editEmailAddress(.didAppear)) {
                $0.editEmailAddress.isEmailValid = true
            },
            .send(.editEmailAddress(.save)) {
                $0.editEmailAddress.savingEmailAddress = true
            },
            .receive(.editEmailAddress(.didReceiveSaveResponse(.success(0)))) {
                $0.editEmailAddress.savingEmailAddress = false
            },
            .receive(.presentStep(.verifyEmailPrompt)) {
                $0.flowStep = .verifyEmailPrompt
            }
        )
    }

    func test_edit_email_edit_and_save_success() throws {
        testStore.assert(
            .send(.editEmailAddress(.didChangeEmailAddress("someone@example.com"))) {
                $0.editEmailAddress.emailAddress = "someone@example.com"
                $0.editEmailAddress.isEmailValid = true
            },
            .send(.editEmailAddress(.save)) {
                $0.editEmailAddress.savingEmailAddress = true
            },
            .receive(.editEmailAddress(.didReceiveSaveResponse(.success(0)))) {
                $0.editEmailAddress.savingEmailAddress = false
                $0.verifyEmail.emailAddress = "someone@example.com"
                $0.emailVerificationHelp.emailAddress = "someone@example.com"
            },
            .receive(.presentStep(.verifyEmailPrompt)) {
                $0.flowStep = .verifyEmailPrompt
            }
        )
    }

    func test_edit_email_attemptingTo_save_invalidEmail_does_nothing() throws {
        testStore.assert(
            .send(.editEmailAddress(.didChangeEmailAddress("someone_example.com"))) {
                $0.editEmailAddress.emailAddress = "someone_example.com"
                $0.editEmailAddress.isEmailValid = false
            },
            .send(.editEmailAddress(.save)) {
                $0.editEmailAddress.savingEmailAddress = false
            }
        )
    }

    func test_edit_email_save_failure() throws {
        let mockService = testStore.environment.emailVerificationService as? MockEmailVerificationService
        mockService?.stubbedResults.updateEmailAddress = .failure(.missingCredentials)
        testStore.assert(
            .send(.editEmailAddress(.didAppear)) {
                $0.editEmailAddress.isEmailValid = true
            },
            .send(.editEmailAddress(.save)) {
                $0.editEmailAddress.savingEmailAddress = true
            },
            .receive(.editEmailAddress(.didReceiveSaveResponse(.failure(.missingCredentials)))) {
                $0.editEmailAddress.savingEmailAddress = false
                $0.editEmailAddress.saveEmailFailureAlert = AlertState(
                    title: TextState(L10n.GenericError.title),
                    message: TextState(L10n.EditEmail.couldNotUpdateEmailAlertMessage),
                    primaryButton: .default(
                        TextState(L10n.GenericError.retryButtonTitle),
                        send: .save
                    ),
                    secondaryButton: .cancel()
                )
            },
            .send(.editEmailAddress(.dismissSaveEmailFailureAlert)) {
                $0.editEmailAddress.saveEmailFailureAlert = nil
            }
        )
    }

    // MARK: Email Verification Help State Manipulation

    func test_help_navigates_to_edit_email() throws {
        testStore.assert(
            .send(.emailVerificationHelp(.editEmailAddress)),
            .receive(.presentStep(.editEmailAddress)) {
                $0.flowStep = .editEmailAddress
            }
        )
    }

    func test_help_resend_verificationEmail_success() throws {
        testStore.assert(
            .send(.emailVerificationHelp(.sendVerificationEmail)) {
                $0.emailVerificationHelp.sendingVerificationEmail = true
            },
            .receive(.emailVerificationHelp(.didReceiveEmailSendingResponse(.success(0)))) {
                $0.emailVerificationHelp.sendingVerificationEmail = false
            },
            .receive(.presentStep(.verifyEmailPrompt)) {
                $0.flowStep = .verifyEmailPrompt
            }
        )
    }

    func test_help_resend_verificationEmail_failure() throws {
        let mockService = testStore.environment.emailVerificationService as? MockEmailVerificationService
        mockService?.stubbedResults.sendVerificationEmail = .failure(.missingCredentials)
        testStore.assert(
            .send(.emailVerificationHelp(.sendVerificationEmail)) {
                $0.emailVerificationHelp.sendingVerificationEmail = true
            },
            .receive(.emailVerificationHelp(.didReceiveEmailSendingResponse(.failure(.missingCredentials)))) {
                $0.emailVerificationHelp.sendingVerificationEmail = false
                $0.emailVerificationHelp.sentFailedAlert = AlertState(
                    title: TextState(L10n.GenericError.title),
                    message: TextState(L10n.EmailVerificationHelp.couldNotSendEmailAlertMessage),
                    primaryButton: .default(
                        TextState(L10n.GenericError.retryButtonTitle),
                        send: .sendVerificationEmail
                    ),
                    secondaryButton: .cancel()
                )
            },
            .send(.emailVerificationHelp(.dismissEmailSendingFailureAlert)) {
                $0.emailVerificationHelp.sentFailedAlert = nil
            }
        )
    }

    // MARK: - Helpers

    private func resetTestStore(emailAddress: String = "test@example.com") {
        testStore = TestStore(
            initialState: EmailVerificationState(emailAddress: emailAddress),
            reducer: emailVerificationReducer,
            environment: EmailVerificationEnvironment(
                emailVerificationService: MockEmailVerificationService(),
                flowCompletionCallback: { [weak self] in
                    self?.recordedInvocations.flowCompletionCallback += 1
                },
                mainQueue: .immediate,
                openMailApp: { [unowned self] in
                    Effect(value: self.stubbedResults.canOpenMailApp)
                }
            )
        )
    }
}
