//
//  APIClient.swift
//  BitcoinChainKit
//
//  Created by Jack Pooley on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import PlatformKit
import RxSwift

public protocol APIClientAPI {
    
    func multiAddress<T: BitcoinChainHistoricalTransactionResponse>(for addresses: [String]) -> Single<BitcoinChainMultiAddressResponse<T>>
    
    func balances(for addresses: [String]) -> Single<BitcoinChainBalanceResponse>
    
    func unspentOutputs(for addresses: [String]) -> Single<UnspentOutputsResponse>
}

final class APIClient: APIClientAPI {
    
    private struct Endpoint {
        
        var multiaddress: [String] {
            base + [ "multiaddr" ]
        }
        
        var balance: [String] {
            base + [ "balance" ]
        }
        
        var unspent: [String] {
            base + [ "unspent" ]
        }
        
        let base: [String]
        
        init(coin: BitcoinChainCoin) {
            self.base = [ coin.rawValue.lowercased() ]
        }
    }
    
    private struct Parameter {
        
        static func active(addresses: [String]) -> URLQueryItem {
            URLQueryItem(
                name: "active",
                value: "\(addresses.joined(separator: "|"))"
            )
        }
    }
    
    private let coin: BitcoinChainCoin
    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder: RequestBuilder
    private let endpoint: Endpoint
    
    // MARK: - Init

    init(coin: BitcoinChainCoin,
         communicator: NetworkCommunicatorAPI = resolve(),
         requestBuilder: RequestBuilder = resolve()) {
        self.coin = coin
        self.communicator = communicator
        self.requestBuilder = requestBuilder
        self.endpoint = Endpoint(coin: coin)
    }
    
    // MARK: - APIClientAPI
    
    func multiAddress<T: BitcoinChainHistoricalTransactionResponse>(for addresses: [String]) -> Single<BitcoinChainMultiAddressResponse<T>> {
        let parameters = [
            Parameter.active(addresses: addresses)
        ]
        let request = requestBuilder.get(
            path: endpoint.multiaddress,
            parameters: parameters,
            recordErrors: true
        )!
        return communicator.perform(request: request)
    }

    func balances(for addresses: [String]) -> Single<BitcoinChainBalanceResponse> {
        let parameters = [
            Parameter.active(addresses: addresses)
        ]
        let request = requestBuilder.get(
            path: endpoint.balance,
            parameters: parameters,
            recordErrors: true
        )!
        return communicator.perform(request: request)
    }
    
    func unspentOutputs(for addresses: [String]) -> Single<UnspentOutputsResponse> {
        let parameters = [
            Parameter.active(addresses: addresses)
        ]
        let request = requestBuilder.post(
            path: endpoint.unspent,
            parameters: parameters,
            recordErrors: true
        )!
        return communicator.perform(request: request)
    }
}
