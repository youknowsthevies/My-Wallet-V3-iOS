// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public protocol EthereumHistoricalTransactionServiceAPI: AnyObject {
    var isWaitingOnTransaction: Single<Bool> { get }
    var transactions: Single<[EthereumHistoricalTransaction]> { get }

    func transaction(identifier: String) -> Single<EthereumHistoricalTransaction>
}

final class EthereumHistoricalTransactionService: EthereumHistoricalTransactionServiceAPI {

    // MARK: - Properties

    var transactions: Single<[EthereumHistoricalTransaction]> {
        cachedTransactions.valueSingle
    }

    var isWaitingOnTransaction: Single<Bool> {
        fetchTransactions()
            .map { $0.contains(where: { $0.state == .pending }) }
            .catchErrorJustReturn(true)
    }

    // MARK: - Private properties

    private var latestBlock: Single<Int> {
        cachedLatestBlock.valueSingle
    }

    private var account: Single<EthereumWalletAccount> {
        accountRepository.defaultAccount.asSingle()
    }

    private let cachedTransactions: CachedValue<[EthereumHistoricalTransaction]>
    private let cachedLatestBlock: CachedValue<Int>
    private let accountRepository: EthereumWalletAccountRepositoryAPI
    private let client: TransactionClientAPI

    // MARK: - Init

    init(accountRepository: EthereumWalletAccountRepositoryAPI = resolve(), client: TransactionClientAPI = resolve()) {
        self.accountRepository = accountRepository
        self.client = client
        cachedTransactions = CachedValue<[EthereumHistoricalTransaction]>(configuration: .periodic(60))
        cachedLatestBlock = CachedValue<Int>(configuration: .periodic(5))

        cachedTransactions.setFetch { [weak self] () -> Single<[EthereumHistoricalTransaction]> in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return self.fetch()
        }

        cachedLatestBlock.setFetch { [weak self] () -> Single<Int> in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return self.fetchLatestBlock()
        }
    }

    /// Triggers transaction fetch and caches the new transactions
    func fetchTransactions() -> Single<[EthereumHistoricalTransaction]> {
        cachedTransactions.fetchValue
    }

    func transaction(identifier: String) -> Single<EthereumHistoricalTransaction> {
        Single
            .zip(account, latestBlock)
            .flatMap { [client] account, latestBlock -> Single<EthereumHistoricalTransaction> in
                client.transaction(with: identifier)
                    .map { response in
                        EthereumHistoricalTransaction(
                            response: response,
                            accountAddress: account.publicKey,
                            latestBlock: latestBlock
                        )
                    }
                    .asSingle()
            }
    }

    // MARK: - Privately used accessors

    private func fetch() -> Single<[EthereumHistoricalTransaction]> {
        Single
            .zip(account, latestBlock)
            .flatMap(weak: self) { (self, tuple) -> Single<[EthereumHistoricalTransaction]> in
                self.fetch(account: tuple.0, latestBlock: tuple.1)
            }
    }

    private func fetch(account: EthereumWalletAccount, latestBlock: Int) -> Single<[EthereumHistoricalTransaction]> {
        client
            .transactions(for: account.publicKey)
            .asSingle()
            .map { response -> [EthereumHistoricalTransaction] in
                response
                    .map { transactionResponse -> EthereumHistoricalTransaction in
                        EthereumHistoricalTransaction(
                            response: transactionResponse,
                            accountAddress: account.publicKey,
                            latestBlock: latestBlock
                        )
                    }
                    // Sort backwards
                    .sorted(by: >)
            }
    }

    private func fetchLatestBlock() -> Single<Int> {
        client.latestBlock
            .map(\.number)
            .asSingle()
    }
}
