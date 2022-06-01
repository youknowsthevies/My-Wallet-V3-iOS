// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import PlatformKit

protocol InterestAccountWithdrawClientAPI: AnyObject {

    func createInterestAccountWithdrawal(
        _ amount: MoneyValue,
        address: String,
        currencyCode: String
    ) -> AnyPublisher<Void, NabuNetworkError>
}
