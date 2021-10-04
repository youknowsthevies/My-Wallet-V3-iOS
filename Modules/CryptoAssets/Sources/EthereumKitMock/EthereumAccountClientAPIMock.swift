// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import EthereumKit
import NetworkError

final class EthereumAccountClientMock: EthereumAccountClientAPI {

    /// The stubbed ethereum is contract response.
    let isContractResponse = EthereumIsContractResponse(contract: false)

    func isContract(address: String) -> AnyPublisher<EthereumIsContractResponse, NetworkError> {
        .just(isContractResponse)
    }
}
