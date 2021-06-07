// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import NetworkKit
import PlatformKit
import RxSwift

public protocol ERC20HistoricalTransactionServiceAPI {
    func transactions(cryptoCurrency: CryptoCurrency, token: String?, size: Int) -> Single<PageResult<ERC20HistoricalTransaction>>
}

final class ERC20HistoricalTransactionService: ERC20HistoricalTransactionServiceAPI {

    private let accountClient: ERC20AccountAPIClientAPI
    private let bridge: EthereumWalletBridgeAPI

    init(bridge: EthereumWalletBridgeAPI = resolve(),
         accountClient: ERC20AccountAPIClientAPI = resolve()) {
        self.bridge = bridge
        self.accountClient = accountClient
    }

    func transactions(cryptoCurrency: CryptoCurrency, token: String?, size: Int) -> Single<PageResult<ERC20HistoricalTransaction>> {
        bridge.address
            .flatMap(weak: self) { (self, address) in
                self.fetchTransactions(cryptoCurrency: cryptoCurrency, address: address, page: token ?? "0")
            }
            .map { transactions in
                PageResult<ERC20HistoricalTransaction>(
                    hasNextPage: transactions.count >= size,
                    items: transactions
                )
            }
    }

    private func fetchTransactions(cryptoCurrency: CryptoCurrency, address: EthereumAddress, page: String) -> Single<[ERC20HistoricalTransaction]> {
        guard let contractAddress = cryptoCurrency.contractAddress else {
            fatalError("Not an ERC20 coin.")
        }
        return accountClient
            .fetchTransactions(from: address.publicKey, page: page, contractAddress: contractAddress)
            .map(\.transfers)
            .map { transfers -> [ERC20HistoricalTransaction] in
                transfers.map { item in
                    ERC20HistoricalTransaction(
                        response: item,
                        cryptoCurrency: cryptoCurrency,
                        source: address
                    )
                }
            }
    }
}
