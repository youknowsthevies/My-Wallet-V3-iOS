//
//  EthereumHistoricalTransactionService.swift
//  EthereumKit
//
//  Created by Jack on 27/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class EthereumHistoricalTransactionService: HistoricalTransactionAPI {
    
    public typealias Bridge = EthereumWalletBridgeAPI
    
    // MARK: - Properties
    
    public var transactions: Single<[EthereumHistoricalTransaction]> {
        cachedTransactions.valueSingle
    }
    
    public var latestTransaction: Single<EthereumHistoricalTransaction?> {
        cachedTransactions.valueSingle.map { $0.first }
    }
    
    /// Streams a boolean indicating whether there are transactions in the account
    public var hasTransactions: Single<Bool> {
        transactions.map { !$0.isEmpty }
    }
    
    // MARK: - Private properties
    
    private var latestBlock: Single<Int> {
        cachedLatestBlock.valueSingle
    }
    
    private var account: Single<EthereumAssetAccount> {
        cachedAccount.valueSingle
    }
    
    private let cachedAccount: CachedValue<EthereumAssetAccount>
    private let cachedTransactions: CachedValue<[EthereumHistoricalTransaction]>
    private let cachedLatestBlock: CachedValue<Int>
    
    private let bridge: Bridge
    private let client: EthereumClientAPI

    // MARK: - Init

    convenience public init(with bridge: Bridge) {
        self.init(with: bridge, client: APIClient())
    }
    
    public init(with bridge: Bridge, client: EthereumClientAPI) {
        self.bridge = bridge
        self.client = client
        self.cachedAccount = CachedValue<EthereumAssetAccount>(configuration: .onSubscriptionAndLogin())
        self.cachedTransactions = CachedValue<[EthereumHistoricalTransaction]>(configuration: .periodicAndLogin(60))
        self.cachedLatestBlock = CachedValue<Int>(configuration: .periodicAndLogin(5))
        
        cachedAccount.setFetch { [weak self] () -> Single<EthereumAssetAccount> in
            guard let self = self else {
                return Single.error(ToolKitError.nullReference(Self.self))
            }
            return self.bridge.account
        }
        
        cachedTransactions.setFetch { [weak self] () -> Single<[EthereumHistoricalTransaction]> in
            guard let self = self else {
                return Single.error(ToolKitError.nullReference(Self.self))
            }
            return self.fetch()
        }
        
        cachedLatestBlock.setFetch { [weak self] () -> Single<Int> in
            guard let self = self else {
                return Single.error(ToolKitError.nullReference(Self.self))
            }
            return self.fetchLatestBlock()
        }
    }
    
    // MARK: - HistoricalTransactionAPI
    
    /// Triggers transaction fetch and caches the new transactions
    public func fetchTransactions() -> Single<[EthereumHistoricalTransaction]> {
        cachedTransactions.fetchValue
    }
    
    public func hasTransactionBeenProcessed(transactionHash: String) -> Single<Bool> {
        transactions
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { $0.contains { $0.transactionHash == transactionHash } }
    }
    
    // MARK: - Privately used accessors

    private func fetch() -> Single<[EthereumHistoricalTransaction]> {
        Single
            .zip(account, latestBlock)
            .flatMap(weak: self) { (self, tuple) -> Single<[EthereumHistoricalTransaction]> in
                self.fetch(account: tuple.0, latestBlock: tuple.1)
            }
    }

    private func fetch(account: EthereumAssetAccount, latestBlock: Int) -> Single<[EthereumHistoricalTransaction]> {
        client
            .transactions(for: account.accountAddress)
            .map(weak: self) { (self, response) -> [EthereumHistoricalTransaction] in
                self.transactions(
                    from: account.accountAddress,
                    latestBlock: latestBlock,
                    response: response
                )
            }
    }
    
    private func fetchLatestBlock() -> Single<Int> {
        client.latestBlock.map { $0.number }
    }

    private func transactions(from address: String,
                              latestBlock: Int,
                              response: [EthereumHistoricalTransactionResponse]) -> [EthereumHistoricalTransaction] {
        response
            .map { transactionResponse -> EthereumHistoricalTransaction in
                EthereumHistoricalTransaction(
                    response: transactionResponse,
                    accountAddress: address,
                    latestBlock: latestBlock
                )
            }
            // Sort backwards
            .sorted(by: >)
    }
}

extension EthereumHistoricalTransactionService: HistoricalTransactionDetailsAPI {

    // MARK: HistoricalTransactionDetailsAPI

    public func transaction(identifier: String) -> Observable<EthereumHistoricalTransaction> {
        cachedTransaction(identifier: identifier)
            .asObservable()
            .flatMap(weak: self) { (self, transaction) in
                let fetch = self.fetchTransaction(identifier: identifier)
                    .asObservable()
                if let transaction = transaction {
                    return fetch.startWith(transaction)
                }
                return fetch
            }
    }

    /// Fetch transaction details from endpoint
    private func fetchTransaction(identifier: String) -> Single<EthereumHistoricalTransaction> {
        Single
            .zip(account, latestBlock)
            .flatMap(weak: self) { (self, tuple) -> Single<EthereumHistoricalTransaction> in
                self.client
                    .transaction(with: identifier)
                    .map { response in
                        EthereumHistoricalTransaction(
                            response: response,
                            accountAddress: tuple.0.accountAddress,
                            latestBlock: tuple.1
                        )
                }
            }
    }

    /// Returns transaction details from local cache if available.
    private func cachedTransaction(identifier: String) -> Single<EthereumHistoricalTransaction?> {
        transactions
            .map { $0.first(where: { $0.identifier == identifier }) }
    }
}
