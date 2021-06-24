// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import OnboardingUIKit
import UIKit

extension TransactionsAdapter: OnboardingUIKit.BuyCryptoRouterAPI {

    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        presentTransactionFlow(to: .buy(nil), from: presenter)
            .map(OnboardingResult.init)
            .eraseToAnyPublisher()
    }
}

extension OnboardingResult {

    init(_ transactionResult: TransactionResult) {
        switch transactionResult {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}
