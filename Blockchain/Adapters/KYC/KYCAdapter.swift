// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import KYCKit
import KYCUIKit
import OnboardingUIKit
import PlatformUIKit // sadly, transactions logic is currently stored here
import ToolKit

final class KYCAdapter {

    // MARK: - Properties

    private let router: KYCUIKit.Routing

    // MARK: - Init

    init(router: KYCUIKit.Routing = resolve()) {
        self.router = router
    }

    // MARK: - Public Interface

    func presentEmailVerificationAndKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<KYCUIKit.FlowResult, KYCUIKit.RouterError> {
        router.presentEmailVerificationAndKYCIfNeeded(from: presenter)
            .eraseToAnyPublisher()
    }

    func presentEmailVerificationIfNeeded(from presenter: UIViewController) -> AnyPublisher<KYCUIKit.FlowResult, KYCUIKit.RouterError> {
        router.presentEmailVerificationIfNeeded(from: presenter)
            .eraseToAnyPublisher()
    }

    func presentKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<KYCUIKit.FlowResult, KYCUIKit.RouterError> {
        router.presentKYCIfNeeded(from: presenter)
            .eraseToAnyPublisher()
    }
}

// MARK: - PlatformUIKit.KYCRouting

extension KYCRouterError {

    init(_ error: KYCUIKit.RouterError) {
        switch error {
        case .emailVerificationFailed:
            self = .emailVerificationFailed
        case .kycVerificationFailed:
            self = .kycVerificationFailed
        case .kycStepFailed:
            self = .kycStepFailed
        }
    }
}

// MARK: - PlatformUIKit.KYCRouting

extension KYCAdapter: PlatformUIKit.KYCRouting {

    func presentEmailVerificationAndKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<Void, KYCRouterError> {
        presentEmailVerificationAndKYCIfNeeded(from: presenter)
            .mapError(KYCRouterError.init)
            .eraseToAnyPublisher()
            .mapToVoid()
    }

    func presentEmailVerificationIfNeeded(from presenter: UIViewController) -> AnyPublisher<Void, KYCRouterError> {
        presentEmailVerificationIfNeeded(from: presenter)
            .mapError(KYCRouterError.init)
            .eraseToAnyPublisher()
            .mapToVoid()
    }

    func presentKYCIfNeeded(from presenter: UIViewController) -> AnyPublisher<Void, KYCRouterError> {
        presentKYCIfNeeded(from: presenter)
            .mapError(KYCRouterError.init)
            .eraseToAnyPublisher()
            .mapToVoid()
    }
}

// MARK: - OnboardingUIKit.EmailVerificationRouterAPI

extension OnboardingResult {

    init(_ result: KYCUIKit.FlowResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}

extension KYCAdapter: OnboardingUIKit.EmailVerificationRouterAPI {

    func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        router.presentEmailVerificationIfNeeded(from: presenter)
            .map(OnboardingResult.init)
            .replaceError(with: OnboardingResult.completed)
            .eraseToAnyPublisher()
    }
}
