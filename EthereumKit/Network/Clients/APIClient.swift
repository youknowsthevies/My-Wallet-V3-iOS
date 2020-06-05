//
//  APIClient.swift
//  EthereumKit
//
//  Created by Jack on 19/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import BigInt
import NetworkKit
import PlatformKit

public protocol EthereumClientAPI: class {

    var latestBlock: Single<LatestBlockResponse> { get }

    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse>
    func transactions(for account: String) -> Single<[EthereumHistoricalTransactionResponse]>
    func transaction(with hash: String) -> Single<EthereumHistoricalTransactionResponse>
    func balanceDetails(from address: String) -> Single<BalanceDetailsResponse>
}

final class APIClient: EthereumClientAPI {

    // MARK: - Types

    /// Potential errors
    enum ClientError: Error {

        /// Error building the request
        case buildingRequest

        /// Balance is missing for address
        case missingBalanceResponseForAddress

        /// Account is missing for
        case missingAccountResponseForAddress
    }

    /// Privately used endpoint data
    private struct Endpoint {
        static let base: [String] = [ "eth" ]

        static let pushTx: [String] = base + [ "pushtx" ]

        static func balance(for address: String) -> [String] {
            base + [ "account", address, "balance" ]
        }

        static func account(for address: String) -> [String] {
            base + [ "account", address ]
        }
    }

    /// Privately used endpoint data
    private struct EndpointV2 {
        private static let base: [String] = [ "v2", "eth", "data" ]
        private static let account: [String] = base + [ "account" ]

        static let latestBlock: [String] = base + [ "block", "latest", "number" ]

        static func transactions(for address: String) -> [String] {
            account + [ address, "transactions" ]
        }

        static func transaction(with hash: String) -> [String] {
            base + [ "transaction", hash ]
        }
    }

    // MARK: - Properties

    /// Streams the latest block
    var latestBlock: Single<LatestBlockResponse> {
        let path = EndpointV2.latestBlock
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return communicator.perform(request: request)
    }

    // MARK: - Private Properties

    private let communicator: NetworkCommunicatorAPI
    private let config: Network.Config
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(communicator: NetworkCommunicatorAPI, config: Network.Config) {
        self.communicator = communicator
        self.config = config
        self.requestBuilder = RequestBuilder(networkConfig: config)
    }

    convenience init(dependencies: Network.Dependencies = .default) {
        self.init(communicator: dependencies.communicator, config: dependencies.blockchainAPIConfig)
    }

    /// Pushes a transaction
    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse> {
        let pushTxRequest = PushTxRequest(
            rawTx: transaction.rawTx,
            api_code: config.apiCode
        )
        let data = try? JSONEncoder().encode(pushTxRequest)
        guard let request = requestBuilder.post(
            path: Endpoint.pushTx,
            body: data,
            recordErrors: true
        ) else {
            return .error(ClientError.buildingRequest)
        }
        return communicator.perform(request: request)
    }

    func transaction(with hash: String) -> Single<EthereumHistoricalTransactionResponse> {
        let path = EndpointV2.transaction(with: hash)
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return communicator.perform(
                request: request,
                responseType: EthereumHistoricalTransactionResponse.self
            )
    }

    /// Fetches transactions for an address - returns an array of transactions
    func transactions(for account: String) -> Single<[EthereumHistoricalTransactionResponse]> {
        let path = EndpointV2.transactions(for: account)
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return communicator.perform(
                request: request,
                responseType: EthereumAccountTransactionsResponse.self
            )
            .map { $0.transactions }
    }

    /// Fetches the balance for an address
    func balanceDetails(from address: String) -> Single<BalanceDetailsResponse> {
        let path = Endpoint.balance(for: address)
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return communicator.perform(request: request)
            .map { (payload: [String: BalanceDetailsResponse]) -> BalanceDetailsResponse in
                guard let details = payload[address] else {
                    throw ClientError.missingBalanceResponseForAddress
                }
                return details
        }
    }
}
