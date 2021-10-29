// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureTransactionUI
import UIKit

final class NoOpTransactionsRouter: TransactionsRouterAPI {

    func presentTransactionFlow(
        to action: TransactionFlowAction
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        Empty().eraseToAnyPublisher()
    }

    func presentTransactionFlow(
        to action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        Empty().eraseToAnyPublisher()
    }
}
