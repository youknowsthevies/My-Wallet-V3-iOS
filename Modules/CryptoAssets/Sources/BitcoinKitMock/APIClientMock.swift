// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
@testable import BitcoinKit
import Combine
import Foundation
import NetworkError
import ToolKit

enum TestAPIClientError: Error {
    case testError
}

class APIClientMock: BitcoinKit.APIClientAPI {

    var underlyingMultiAddress: AnyPublisher<BitcoinMultiAddressResponse, NetworkError> =
        .failure(.authentication(TestAPIClientError.testError))

    func multiAddress(
        for addresses: [XPub]
    ) -> AnyPublisher<BitcoinMultiAddressResponse, NetworkError> {
        underlyingMultiAddress
    }

    var underlyingBalances: AnyPublisher<BitcoinBalanceResponse, NetworkError> =
        .failure(.authentication(TestAPIClientError.testError))

    func balances(
        for addresses: [XPub]
    ) -> AnyPublisher<BitcoinBalanceResponse, NetworkError> {
        underlyingBalances
    }

    var underlyingUnspentOutputs: AnyPublisher<UnspentOutputsResponse, NetworkError> =
        .failure(.authentication(TestAPIClientError.testError))

    func unspentOutputs(
        for addresses: [XPub]
    ) -> AnyPublisher<UnspentOutputsResponse, NetworkError> {
        underlyingUnspentOutputs
    }
}
