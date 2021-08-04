// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct InterestAccountLimits {

    // MARK: - Public Properties

    public let interestLockupDuration: Double
    public let cryptoCurrency: CryptoCurrency
    public let nextInterestPayment: Date
    public let minDepositAmount: FiatValue
    public let maxWithdrawalAmount: FiatValue

    // MARK: - Init

    init(
        _ response: InterestLimits,
        cryptoCurrency: CryptoCurrency
    ) {
        interestLockupDuration = response.lockUpDuration
        self.cryptoCurrency = cryptoCurrency
        nextInterestPayment = Date()
        minDepositAmount = response.minDepositAmount
        maxWithdrawalAmount = response.maxWithdrawalAmount
    }
}
