// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import KYCKit
import UIKit

public enum FlowResult {
    case abandoned
    case completed
}

public enum RouterError: Error {
    case emailVerificationFailed
    case kycVerificationFailed
    case kycStepFailed
}

public protocol Routing {

    /// Uses the passed-in `ViewController`to modally present another `ViewController` wrapping the entire Email Verification Flow.
    /// - Parameters:
    ///   - presenter: The `ViewController` presenting the Email Verification Flow
    ///   - emailAddress: The initial email address to verify. Note that users may change their email address in the course of the verification flow.
    ///   - flowCompletion: A closure called after the Email Verification Flow completes successully (with the email address being verified).
    func routeToEmailVerification(from presenter: UIViewController, emailAddress: String, flowCompletion: @escaping (FlowResult) -> Void)

    /// Uses the passed-in `ViewController`to modally present another `ViewController` wrapping the entire KYC Flow.
    /// - Parameters:
    ///   - presenter: The `ViewController` presenting the KYC Flow
    ///   - flowCompletion: A closure called after the KYC Flow completes successully (with the email address being verified).
    func routeToKYC(from presenter: UIViewController, flowCompletion: @escaping (FlowResult) -> Void)

    // Convenience Combine APIs

    func presentEmailVerificationAndKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<FlowResult, RouterError>
    func presentEmailVerificationIfNeeded(from presenter: UIViewController) -> AnyPublisher<FlowResult, RouterError>
    func presentKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<FlowResult, RouterError>
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

    public func routeToEmailVerification(from presenter: UIViewController, emailAddress: String, flowCompletion: @escaping (FlowResult) -> Void) {
        presenter.present(
            EmailVerificationView(
                store: .init(
                    initialState: .init(emailAddress: emailAddress),
                    reducer: emailVerificationReducer,
                    environment: buildEmailVerificationEnvironment(
                        emailAddress: emailAddress,
                        flowCompletion: flowCompletion
                    )
                )
            )
        )
    }

    public func routeToKYC(from presenter: UIViewController, flowCompletion: @escaping (FlowResult) -> Void) {
        // TODO: present KYC Flow if needed (IOS-4471)
        fatalError("Unimplemented")
    }

    public func presentEmailVerificationAndKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<FlowResult, RouterError> {
        // step 1: check email verification status and present email verification flow if email is unverified.
        presentEmailVerificationIfNeeded(from: presenter)
            // step 2: check KYC status and present KYC flow if user is not verified.
            .flatMap { [presentKYCIfNeeded] _ in
                presentKYCIfNeeded(presenter)
            }
            .eraseToAnyPublisher()
    }

    public func presentEmailVerificationIfNeeded(from presenter: UIViewController) -> AnyPublisher<FlowResult, RouterError> {
        emailVerificationService
            // step 1: check email verification status.
            .checkEmailVerificationStatus()
            .mapError { _ in
                RouterError.emailVerificationFailed
            }
            .receive(on: DispatchQueue.main)
            // step 2: present email verification screen, if needed.
            .flatMap { response -> AnyPublisher<FlowResult, RouterError> in
                switch response.status {
                case .verified:
                    // The user's email address is verified; no need to do anything. Just move on.
                    return .just(.completed)

                case .unverified:
                    // The user's email address in NOT verified; present email verification flow.
                    let publisher = PassthroughSubject<FlowResult, RouterError>()
                    self.routeToEmailVerification(from: presenter, emailAddress: response.emailAddress) { result in
                        switch result {
                        case .abandoned:
                            publisher.send(.abandoned)
                        case .completed:
                            publisher.send(.completed)
                        }
                        publisher.send(completion: .finished)
                    }
                    return publisher.eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    public func presentKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<FlowResult, RouterError> {
        // step 1: check KYC status.
        // TODO: check KYC status and present KYC Flow if needed (IOS-4471)
        fatalError("Unimplemented")
    }

    // MARK: - Helpers

    func buildEmailVerificationEnvironment(emailAddress: String, flowCompletion: @escaping (FlowResult) -> Void) -> EmailVerificationEnvironment {
        EmailVerificationEnvironment(
            emailVerificationService: emailVerificationService,
            flowCompletionCallback: flowCompletion,
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
