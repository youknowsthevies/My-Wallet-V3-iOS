// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

public protocol CustodialTransferRepositoryAPI {

    // MARK: - Types

    typealias CustodialWithdrawalIdentifier = String

    // MARK: - Methods

    func transfer(
        moneyValue: MoneyValue,
        destination: String,
        memo: String?
    ) -> AnyPublisher<CustodialWithdrawalIdentifier, NabuNetworkError>

    func feesAndLimitsForInterest() -> AnyPublisher<CustodialTransferFee, NabuNetworkError>

    func fees() -> AnyPublisher<CustodialTransferFee, NabuNetworkError>
}
