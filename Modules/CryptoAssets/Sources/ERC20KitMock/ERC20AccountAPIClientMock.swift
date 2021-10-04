// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import ERC20Kit
import NetworkError
import ToolKit

final class ERC20AccountAPIClientMock: ERC20AccountAPIClientAPI {

    var fetchTransactionsResponse: AnyPublisher<ERC20TransfersResponse, NetworkError> =
        .just(.transfersResponse)

    func fetchTransactions(
        from address: String,
        page: String?,
        contractAddress: String
    ) -> AnyPublisher<ERC20TransfersResponse, NetworkError> {
        fetchTransactionsResponse
    }
}
