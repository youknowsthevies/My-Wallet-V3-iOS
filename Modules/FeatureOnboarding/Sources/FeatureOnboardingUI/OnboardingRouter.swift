// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit
import UIKit

public protocol EmailVerificationRouterAPI {
    func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
}

public protocol OnboardingTransactionsRouterAPI {
    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
    func navigateToBuyCryptoFlow(from presenter: UIViewController)
    func navigateToReceiveCryptoFlow(from presenter: UIViewController)
}

public class OnboardingRouter: OnboardingRouterAPI {

    // MARK: - Properties

    let transactionsRouter: OnboardingTransactionsRouterAPI
    let emailVerificationRouter: EmailVerificationRouterAPI
    let featureFlagsService: FeatureFlagsServiceAPI

    // MARK: - Init

    public init(
        transactionsRouter: OnboardingTransactionsRouterAPI = resolve(),
        emailVerificationRouter: EmailVerificationRouterAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        self.transactionsRouter = transactionsRouter
        self.emailVerificationRouter = emailVerificationRouter
        self.featureFlagsService = featureFlagsService
    }

    // MARK: - Onboarding Routing

    public func presentOnboarding(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        // Step 1: present email verification
        presentEmailVerification(from: presenter)
            .receive(on: DispatchQueue.main)
            .flatMap { [transactionsRouter] result -> AnyPublisher<OnboardingResult, Never> in
                guard case .completed = result else {
                    return .just(.abandoned)
                }
                // Step 2: present the buy flow
                return transactionsRouter.presentBuyFlow(from: presenter)
            }
            .eraseToAnyPublisher()
    }

    public func presentRequiredCryptoBalanceView(
        from presenter: UIViewController
    ) -> AnyPublisher<OnboardingResult, Never> {
        let subject = PassthroughSubject<OnboardingResult, Never>()
        let view = CryptoBalanceRequiredView(
            store: .init(
                initialState: (),
                reducer: CryptoBalanceRequired.reducer,
                environment: CryptoBalanceRequired.Environment(
                    close: {
                        presenter.dismiss(animated: true) {
                            subject.send(.abandoned)
                            subject.send(completion: .finished)
                        }
                    },
                    presentBuyFlow: { [transactionsRouter] in
                        presenter.dismiss(animated: true) {
                            transactionsRouter.navigateToBuyCryptoFlow(from: presenter)
                        }
                    },
                    presentRequestCryptoFlow: { [transactionsRouter] in
                        presenter.dismiss(animated: true) {
                            transactionsRouter.navigateToReceiveCryptoFlow(from: presenter)
                        }
                    }
                )
            )
        )
        presenter.present(view)
        return subject.eraseToAnyPublisher()
    }

    // MARK: - Helper Methods

    private func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        featureFlagsService.isEnabled(.remote(.showEmailVerificationInOnboarding))
            .flatMap { [emailVerificationRouter] shouldShowEmailVerification -> AnyPublisher<OnboardingResult, Never> in
                guard shouldShowEmailVerification else {
                    return .just(.completed)
                }
                return emailVerificationRouter.presentEmailVerification(from: presenter)
            }
            .eraseToAnyPublisher()
    }
}
