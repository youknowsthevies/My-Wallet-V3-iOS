// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import KYCKit
import UIKit

public enum FlowResult {
    case abandoned
    case completed
}

public protocol Routing {

    /// Uses the passed-in `ViewController`to modally present another `ViewController` wrapping the entire Email Verification Flow.
    /// - Parameters:
    ///   - origin: The `ViewController` presenting the Email Verification Flow
    ///   - emailAddress: The initial email address to verify. Note that users may change their email address in the course of the verification flow.
    ///   - flowCompletion: A closure called after the Email Verification Flow completes successully (with the email address being verified).
    func routeToEmailVerification(from origin: UIViewController, emailAddress: String, flowCompletion: @escaping (FlowResult) -> Void)
}

/// A class that encapsulates routing logic for the KYC flow. Use this to present the app user with any part of the KYC flow.
public class Router: Routing {

    public let emailVerificationService: EmailVerificationServiceAPI
    public let openMailApp: (@escaping (Bool) -> Void) -> Void

    public init(
        emailVerificationService: EmailVerificationServiceAPI,
        openMailApp: @escaping (@escaping (Bool) -> Void) -> Void
    ) {
        self.emailVerificationService = emailVerificationService
        self.openMailApp = openMailApp
    }

    public func routeToEmailVerification(from origin: UIViewController, emailAddress: String, flowCompletion: @escaping (FlowResult) -> Void) {
        origin.present(
            view: EmailVerificationView(
                store: .init(
                    initialState: .init(emailAddress: emailAddress),
                    reducer: emailVerificationReducer,
                    environment: buildEmailVerificationEnvironment(
                        emailAddress: emailAddress,
                        flowCompletion: flowCompletion
                    )
                )
            ),
            inNavigationController: false
        )
    }

    func buildEmailVerificationEnvironment(emailAddress: String, flowCompletion: @escaping (FlowResult) -> Void) -> EmailVerificationEnvironment {
        EmailVerificationEnvironment(
            emailVerificationService: emailVerificationService,
            flowCompletionCallback: flowCompletion,
            mainQueue: .main,
            openMailApp: { [openMailApp] in
                .future { callback in
                    openMailApp { result in
                        callback(.success(result))
                    }
                }
            }
        )
    }
}
