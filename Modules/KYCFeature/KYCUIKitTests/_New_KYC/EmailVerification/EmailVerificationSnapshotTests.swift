// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import KYCUIKit
import SnapshotTesting
import SwiftUI
import XCTest

final class EmailVerificationSnapshotTests: XCTestCase {

    private var environment: EmailVerificationEnvironment!
    private var rootStore: Store<EmailVerificationState, EmailVerificationAction>!
    private var mockEmailVerificationService: MockEmailVerificationService!

    enum Config {
        static let minOSRequired: String = "14"
        static let recordingSnapshots: Bool = false
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        isRecording = Config.recordingSnapshots

        mockEmailVerificationService = MockEmailVerificationService()
        environment = EmailVerificationEnvironment(
            emailVerificationService: mockEmailVerificationService,
            flowCompletionCallback: {},
            mainQueue: .immediate,
            openMailApp: { .none }
        )
        rebuildRootStore()
    }

    override func tearDownWithError() throws {
        mockEmailVerificationService = nil
        environment = nil
        rootStore = nil
        try super.tearDownWithError()
    }

    func test_iPhoneSE_snapshot_step_verify_email() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = VerifyEmailView(
            store: rootStore.scope(
                state: \.verifyEmail,
                action: EmailVerificationAction.verifyEmail
            )
        )
        assert(view, on: .iPhoneSe, renderInWindow: true)
    }

    func test_iPhone8_snapshot_step_verify_email() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = VerifyEmailView(
            store: rootStore.scope(
                state: \.verifyEmail,
                action: EmailVerificationAction.verifyEmail
            )
        )
        assert(view, on: .iPhone8, renderInWindow: true)
    }

    func test_iPhoneX_snapshot_step_verify_email() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = VerifyEmailView(
            store: rootStore.scope(
                state: \.verifyEmail,
                action: EmailVerificationAction.verifyEmail
            )
        )
        assert(view, on: .iPhoneX, renderInWindow: true)
    }

    func test_iPhoneSE_snapshot_step_help() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationHelpView(
            store: rootStore.scope(
                state: \.emailVerificationHelp,
                action: EmailVerificationAction.emailVerificationHelp
            )
        )
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_help() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationHelpView(
            store: rootStore.scope(
                state: \.emailVerificationHelp,
                action: EmailVerificationAction.emailVerificationHelp
            )
        )
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_help() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationHelpView(
            store: rootStore.scope(
                state: \.emailVerificationHelp,
                action: EmailVerificationAction.emailVerificationHelp
            )
        )
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_help_resending() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationHelpView(
            store: rootStore.scope(
                state: \.emailVerificationHelp,
                action: EmailVerificationAction.emailVerificationHelp
            )
        )
        mockEmailVerificationService.stubbedResults.sendVerificationEmail = .empty()
        view.viewStore.send(.sendVerificationEmail)
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_help_resending() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationHelpView(
            store: rootStore.scope(
                state: \.emailVerificationHelp,
                action: EmailVerificationAction.emailVerificationHelp
            )
        )
        mockEmailVerificationService.stubbedResults.sendVerificationEmail = .empty()
        view.viewStore.send(.sendVerificationEmail)
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_help_resending() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationHelpView(
            store: rootStore.scope(
                state: \.emailVerificationHelp,
                action: EmailVerificationAction.emailVerificationHelp
            )
        )
        mockEmailVerificationService.stubbedResults.sendVerificationEmail = .empty()
        view.viewStore.send(.sendVerificationEmail)
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_help_resend_failed() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationHelpView(
            store: rootStore.scope(
                state: \.emailVerificationHelp,
                action: EmailVerificationAction.emailVerificationHelp
            )
        )
        view.viewStore.send(.didReceiveEmailSendingResponse(.failure(.missingCredentials)))
        assert(view, on: .iPhoneSe, renderInWindow: true)
    }

    func test_iPhone8_snapshot_step_help_resend_failed() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationHelpView(
            store: rootStore.scope(
                state: \.emailVerificationHelp,
                action: EmailVerificationAction.emailVerificationHelp
            )
        )
        view.viewStore.send(.didReceiveEmailSendingResponse(.failure(.missingCredentials)))
        assert(view, on: .iPhone8, renderInWindow: true)
    }

    func test_iPhoneX_snapshot_step_help_resend_failed() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationHelpView(
            store: rootStore.scope(
                state: \.emailVerificationHelp,
                action: EmailVerificationAction.emailVerificationHelp
            )
        )
        view.viewStore.send(.didReceiveEmailSendingResponse(.failure(.missingCredentials)))
        assert(view, on: .iPhoneX, renderInWindow: true)
    }

    func test_iPhoneSE_snapshot_step_edit_email() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_edit_email() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_edit_email() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_edit_email_invalid() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        rebuildRootStore(emailAddress: "test_example.com")
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_edit_email_invalid() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        rebuildRootStore(emailAddress: "test_example.com")
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_edit_email_invalid() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        rebuildRootStore(emailAddress: "test_example.com")
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_edit_saving() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        mockEmailVerificationService.stubbedResults.updateEmailAddress = .empty()
        view.viewStore.send(.save)
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_edit_saving() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        mockEmailVerificationService.stubbedResults.updateEmailAddress = .empty()
        view.viewStore.send(.save)
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_edit_saving() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        mockEmailVerificationService.stubbedResults.updateEmailAddress = .empty()
        view.viewStore.send(.save)
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_edit_save_failed() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        view.viewStore.send(.didReceiveSaveResponse(.failure(.missingCredentials)))
        assert(view, on: .iPhoneSe, renderInWindow: true)
    }

    func test_iPhone8_snapshot_step_edit_save_failed() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        view.viewStore.send(.didReceiveSaveResponse(.failure(.missingCredentials)))
        assert(view, on: .iPhone8, renderInWindow: true)
    }

    func test_iPhoneX_snapshot_step_edit_save_failed() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EditEmailView(
            store: rootStore.scope(
                state: \.editEmailAddress,
                action: EmailVerificationAction.editEmailAddress
            )
        )
        view.viewStore.send(.didReceiveSaveResponse(.failure(.missingCredentials)))
        assert(view, on: .iPhoneX, renderInWindow: true)
    }

    func test_iPhoneSE_snapshot_step_email_verified() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerifiedView(
            store: rootStore.scope(
                state: \.emailVerified,
                action: EmailVerificationAction.emailVerified
            )
        )
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_email_verified() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerifiedView(
            store: rootStore.scope(
                state: \.emailVerified,
                action: EmailVerificationAction.emailVerified
            )
        )
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_email_verified() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerifiedView(
            store: rootStore.scope(
                state: \.emailVerified,
                action: EmailVerificationAction.emailVerified
            )
        )
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_loading_verification_status() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.loadingVerificationState))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_loading_verification_status() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.loadingVerificationState))
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_loading_verification_status() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.loadingVerificationState))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_loading_verification_status_failed() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.didReceiveEmailVerficationResponse(.failure(.nabuError(.mockError))))
        assert(view, on: .iPhoneSe, renderInWindow: true)
    }

    func test_iPhone8_snapshot_step_loading_verification_status_failed() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.didReceiveEmailVerficationResponse(.failure(.nabuError(.mockError))))
        assert(view, on: .iPhone8, renderInWindow: true)
    }

    func test_iPhoneX_snapshot_step_loading_verification_status_failed() throws {
        try XCTSkipUnless(UIDevice.current.systemVersion.contains(Config.minOSRequired))
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.didReceiveEmailVerficationResponse(.failure(.nabuError(.mockError))))
        assert(view, on: .iPhoneX, renderInWindow: true)
    }

    // MARK: - Helpers

    private func rebuildRootStore(emailAddress: String = "test@example.com") {
        rootStore = Store(
            initialState: EmailVerificationState(emailAddress: emailAddress),
            reducer: emailVerificationReducer,
            environment: environment
        )
    }
}
