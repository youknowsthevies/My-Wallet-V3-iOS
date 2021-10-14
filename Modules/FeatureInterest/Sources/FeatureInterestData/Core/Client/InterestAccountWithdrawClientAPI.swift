// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError
import PlatformKit

protocol InterestAccountWithdrawClientAPI: AnyObject {

    func createInterestAccountWithdrawal(
        _ amount: MoneyValue,
        address: String,
        currencyCode: String
    ) -> AnyPublisher<Void, NabuNetworkError>
}
