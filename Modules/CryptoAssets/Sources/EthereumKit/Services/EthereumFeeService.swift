// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit

/// Service that provides fees to transact EVM tokens.
public protocol EthereumFeeServiceAPI {
    /// Streams a single `EthereumTransactionFee`, representing suggested fee amounts based on mempool.
    /// Never fails, uses default Fee values if network call fails.
    /// - Parameter cryptoCurrency: An EVM Native token or ERC20 token.
    func fees(cryptoCurrency: CryptoCurrency) -> AnyPublisher<EthereumTransactionFee, Never>
}

final class EthereumFeeService: EthereumFeeServiceAPI {

    // MARK: - CryptoFeeServiceAPI

    func fees(cryptoCurrency: CryptoCurrency) -> AnyPublisher<EthereumTransactionFee, Never> {
        let network = cryptoCurrency.assetModel.evmNetwork!
        return client
            .fees(cryptoCurrency: cryptoCurrency)
            .map { response in
                EthereumTransactionFee(
                    regular: response.regular,
                    priority: response.priority,
                    gasLimit: response.gasLimit,
                    gasLimitContract: response.gasLimitContract,
                    network: network
                )
            }
            .replaceError(with: EthereumTransactionFee.default(network: network))
            .eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let client: TransactionFeeClientAPI

    // MARK: - Init

    init(client: TransactionFeeClientAPI = resolve()) {
        self.client = client
    }
}
