// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import ERC20Kit
import NetworkError
import ToolKit

final class ERC20AccountAPIClientMock: ERC20AccountAPIClientAPI {

    // MARK: - Private Properties

    private let fetchTransactionsResponse: AnyPublisher<ERC20TransfersResponse, NetworkError> =
        .just(.transfersResponse)

    private let isContractResponse: AnyPublisher<ERC20IsContractResponse, NetworkError> =
        .just(ERC20IsContractResponse(contract: false))

    // MARK: - Internal Methods

    func fetchTransactions(
        from address: String,
        page: String?,
        contractAddress: String
    ) -> AnyPublisher<ERC20TransfersResponse, NetworkError> {
        fetchTransactionsResponse
    }

    func isContract(
        address: String
    ) -> AnyPublisher<ERC20IsContractResponse, NetworkError> {
        isContractResponse
    }
}
