// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import Errors
import PlatformKit

enum APIClientError: Error {
    case unknown
}

protocol APIClientAPI {

    func multiAddress(for wallets: [XPub]) -> AnyPublisher<BitcoinCashMultiAddressResponse, NetworkError>

    func balances(for wallets: [XPub]) -> AnyPublisher<BitcoinCashBalanceResponse, NetworkError>
}

final class APIClient: APIClientAPI {

    private let client: BitcoinChainKit.APIClientAPI

    // MARK: - Init

    init(client: BitcoinChainKit.APIClientAPI = resolve(tag: BitcoinChainCoin.bitcoinCash)) {
        self.client = client
    }

    // MARK: - APIClientAPI

    func multiAddress(
        for wallets: [XPub]
    ) -> AnyPublisher<BitcoinCashMultiAddressResponse, NetworkError> {
        client.multiAddress(for: wallets)
    }

    func balances(
        for wallets: [XPub]
    ) -> AnyPublisher<BitcoinCashBalanceResponse, NetworkError> {
        client.balances(for: wallets)
    }
}
