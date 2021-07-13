// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import KYCKit
import KYCUIKit
import OnboardingUIKit
import PlatformKit
import PlatformUIKit // sadly, transactions logic is currently stored here
import RxSwift
import ToolKit

final class KYCAdapter {

    // MARK: - Properties

    private let router: KYCUIKit.Routing
    private let legacyRouter: PlatformUIKit.KYCRouterAPI

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        router: KYCUIKit.Routing = resolve(),
        legacyRouter: PlatformUIKit.KYCRouterAPI = resolve()
    ) {
        self.router = router
        self.legacyRouter = legacyRouter
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

extension KYCAdapter: PlatformUIKit.TierUpgradeRouterAPI {

    func presentPromptToUpgradeTier(from presenter: UIViewController?, completion: @escaping () -> Void) {
        guard let presenter = presenter ?? UIApplication.shared.topMostViewController else {
            fatalError("A view controller was expected to exist to run \(#function) in \(#file)")
        }
        router.presentPromptToUnlockMoreTrading(from: presenter)
            .setFailureType(to: Error.self) // to make the following code compile
            .flatMap { [legacyRouter] result -> AnyPublisher<Void, Error> in
                switch result {
                case .abandoned:
                    return Empty(
                        completeImmediately: true,
                        outputType: Void.self,
                        failureType: Error.self
                    ) // simply return to the prompt.
                    .eraseToAnyPublisher()
                case .completed:
                    legacyRouter.start(tier: .tier2, parentFlow: .simpleBuy)
                    return Observable.merge(
                        legacyRouter.kycStopped,
                        legacyRouter.kycFinished
                            .mapToVoid()
                    )
                    .asPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                // if the result is a successful completion, do nothing
                // we should have called the completion block aready on receive value
                guard case .failure = result else {
                    return
                }
                completion()
            }, receiveValue: { _ in
                completion()
            })
            .store(in: &cancellables)
    }
}
