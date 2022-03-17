// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
@testable import BitcoinKit

import Combine
import NetworkError

class APIClientMock: BitcoinKit.APIClientAPI {
    var multiAddressResult: Result<BitcoinMultiAddressResponse, NetworkError> = .failure(
        NetworkError.serverError(.badResponse)
    )

    func multiAddress(
        for addresses: [XPub]
    ) -> AnyPublisher<BitcoinMultiAddressResponse, NetworkError> {
        multiAddressResult
            .publisher
            .eraseToAnyPublisher()
    }

    func balances(
        for addresses: [XPub]
    ) -> AnyPublisher<BitcoinBalanceResponse, NetworkError> {
        .failure(.serverError(.badResponse))
    }

    func unspentOutputs(
        for addresses: [XPub]
    ) -> AnyPublisher<UnspentOutputsResponse, NetworkError> {
        .failure(.serverError(.badResponse))
    }
}
