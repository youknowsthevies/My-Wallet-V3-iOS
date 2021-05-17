// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import KYCKit
import PlatformUIKit
import SharedPackagesKit
import UIKit

/// A class that encapsulates routing logic for the KYC flow. Use this to present the app user with any part of the KYC flow.
public class Router {

    public let emailVerificationService: EmailVerificationServiceAPI
    public let externalAppOpener: ExternalAppOpener

    public init(emailVerificationService: EmailVerificationServiceAPI, externalAppOpener: ExternalAppOpener) {
        self.emailVerificationService = emailVerificationService
        self.externalAppOpener = externalAppOpener
    }

    /// Uses the passed-in `ViewController`to modally present another `ViewController` wrapping the entire Email Verification Flow.
    /// - Parameters:
    ///   - origin: The `ViewController` presenting the Email Verification Flow
    ///   - emailAddress: The initial email address to verify. Note that users may change their email address in the course of the verification flow.
    ///   - flowCompletion: A closure called after the Email Verification Flow completes successully (with the email address being verified).
    /// - Note: The `flowCompletion` closure won't be called if the user manually dismisses the view controller.
    public func routeToEmailVerification(from origin: UIViewController, emailAddress: String, flowCompletion: @escaping () -> Void) {
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

    func buildEmailVerificationEnvironment(emailAddress: String, flowCompletion: @escaping () -> Void) -> EmailVerificationEnvironment {
        EmailVerificationEnvironment(
            emailVerificationService: emailVerificationService,
            flowCompletionCallback: flowCompletion,
            mainQueue: .main,
            openMailApp: { [externalAppOpener] in
                .future { callback in
                    externalAppOpener.openMailApp { result in
                        callback(.success(result))
                    }
                }
            }
        )
    }
}
