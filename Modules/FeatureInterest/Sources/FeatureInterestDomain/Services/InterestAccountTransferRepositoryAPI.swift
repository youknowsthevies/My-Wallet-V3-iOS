// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import PlatformKit

public enum InterestAccountTransferRepositoryError: Error {
    case networkError(Error)
}

public protocol InterestAccountTransferRepositoryAPI {

    func createInterestAccountCustodialTransfer(
        _ amount: MoneyValue
    ) -> AnyPublisher<Void, InterestAccountWithdrawRepositoryError>

    func createInterestAccountCustodialWithdraw(
        _ amount: MoneyValue
    ) -> AnyPublisher<Void, InterestAccountWithdrawRepositoryError>
}
