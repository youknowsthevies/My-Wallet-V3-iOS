// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import OnboardingUIKit
import TransactionUIKit

final class TransactionsAdapter {

    let router: TransactionUIKit.TransactionsRouterAPI

    init(router: TransactionUIKit.TransactionsRouterAPI = resolve()) {
        self.router = router
    }

    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<TransactionFlowResult, Never> {
        router.presentBuyFlow(from: presenter)
    }
}

// MARK: - OnboardingUIKit.BuyCryptoRouterAPI

extension OnboardingResult {

    init(_ transactionResult: TransactionFlowResult) {
        switch transactionResult {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}

extension TransactionsAdapter: OnboardingUIKit.BuyCryptoRouterAPI {

    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        presentBuyFlow(from: presenter)
            .map(OnboardingResult.init)
            .eraseToAnyPublisher()
    }
}
