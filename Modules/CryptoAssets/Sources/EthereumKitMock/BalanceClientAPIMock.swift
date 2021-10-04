// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import EthereumKit
import NetworkError
import PlatformKit

class BalanceClientAPIMock: BalanceClientAPI {

    var balanceDetailsValue: AnyPublisher<BalanceDetailsResponse, ClientError> =
        .failure(.networkError(.authentication(EthereumAPIClientMockError.mockError)))

    func balanceDetails(
        from address: String
    ) -> AnyPublisher<BalanceDetailsResponse, ClientError> {
        balanceDetailsValue
    }
}
