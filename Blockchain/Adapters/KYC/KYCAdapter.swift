// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import KYCKit
import KYCUIKit
import PlatformUIKit // sadly, transactions logic is currently stored here
import ToolKit

final class KYCAdapter {

    // MARK: - Properties

    private let kycRouter: KYCUIKit.Routing
    private let emailVerificationService: EmailVerificationServiceAPI

    // MARK: - Init

    init(
        router: KYCUIKit.Routing,
        emailVerificationService: EmailVerificationServiceAPI
    ) {
        self.kycRouter = router
        self.emailVerificationService = emailVerificationService
    }

    // MARK: - Public Interface

    func presentEmailVerificationAndKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<Void, KYCRouterError> {
        // step 1: check email verification status and present email verification flow if email is unverified.
        presentEmailVerificationIfNeeded(from: presenter)
            // step 2: check KYC status and present KYC flow if user is not verified.
            .flatMap { [presentKYCIfNeeded] _ in
                presentKYCIfNeeded(presenter)
            }
            .eraseToAnyPublisher()
    }

    func presentEmailVerificationIfNeeded(from presenter: UIViewController) -> AnyPublisher<Void, KYCRouterError> {
        emailVerificationService
            // step 1: check email verification status.
            .checkEmailVerificationStatus()
            .mapError { _ in
                KYCRouterError.emailVerificationFailed
            }
            .receive(on: DispatchQueue.main)
            // step 2: present email verification screen, if needed.
            .flatMap { [kycRouter] response -> AnyPublisher<Void, KYCRouterError> in
                switch response.status {
                case .verified:
                    // The user's email address is verified; no need to do anything. Just move on.
                    return .just(())

                case .unverified:
                    // The user's email address in NOT verified; present email verification flow.
                    return Future { callback in
                        kycRouter.routeToEmailVerification(from: presenter, emailAddress: response.emailAddress) { result in
                            switch result {
                            case .abandoned:
                                presenter.dismiss(animated: true, completion: {
                                    callback(.failure(.emailVerificationAbandoned))
                                })
                            case .completed:
                                presenter.dismiss(animated: true, completion: {
                                    callback(.success(()))
                                })
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func presentKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<Void, KYCRouterError> {
        // step 1: check KYC status.
        // TODO: check KYC status (IOS-4471)
        AnyPublisher<Void, KYCRouterError>.just(())
            .receive(on: DispatchQueue.main)
            // step 2: present KYC flow from where the user left off, if needed.
            .flatMap { value -> AnyPublisher<Void, KYCRouterError> in
                // TODO: present KYC Flow if needed (IOS-4471)
                return .just(value)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - PlatformUIKit.KYCRouting

extension KYCAdapter: PlatformUIKit.KYCRouting {}
