// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import Combine
import Foundation
import NetworkError
import ToolKit

enum TestAPIClientError: Error {
    case testError
}

class APIClientMock: BitcoinChainKit.APIClientAPI {

    var underlyingUnspentOutputs: AnyPublisher<UnspentOutputsResponse, NetworkError> =
        .failure(.authentication(TestAPIClientError.testError))

    func multiAddress<T: BitcoinChainHistoricalTransactionResponse>(
        for wallets: [XPub]
    ) -> AnyPublisher<BitcoinChainMultiAddressResponse<T>, NetworkError> {
        .failure(.authentication(TestAPIClientError.testError))
    }

    func balances(
        for wallets: [XPub]
    ) -> AnyPublisher<BitcoinChainBalanceResponse, NetworkError> {
        .failure(.authentication(TestAPIClientError.testError))
    }

    func unspentOutputs(
        for wallets: [XPub]
    ) -> AnyPublisher<UnspentOutputsResponse, NetworkError> {
        underlyingUnspentOutputs
    }
}
