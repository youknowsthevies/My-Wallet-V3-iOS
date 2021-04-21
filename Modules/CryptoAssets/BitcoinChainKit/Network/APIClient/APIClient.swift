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

public enum DerivationType: String, Codable {
    case legacy
    case bech32
}

public struct APIWalletModel {
    let publicKey: String
    let derivationType: DerivationType

    public init(publicKey: String, type: DerivationType) {
        self.publicKey = publicKey
        self.derivationType = type
    }
}

public protocol APIClientAPI {
    
    func multiAddress<T: BitcoinChainHistoricalTransactionResponse>(for wallets: [APIWalletModel]) -> Single<BitcoinChainMultiAddressResponse<T>>
    
    func balances(for wallets: [APIWalletModel]) -> Single<BitcoinChainBalanceResponse>
    
    func unspentOutputs(for wallets: [APIWalletModel]) -> Single<UnspentOutputsResponse>
}

fileprivate extension DerivationType {
    var activaParameter: String {
        switch self {
        case .legacy:
            return "active"
        case .bech32:
            return "activeBech32"
        }
    }
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
        static func active(wallets: [APIWalletModel]) -> [URLQueryItem] {
            wallets
                .reduce(into: [DerivationType: [String]]()) { (result, wallet) in
                    var list = result[wallet.derivationType] ?? []
                    list.append(wallet.publicKey)
                    result[wallet.derivationType] = list
                }
                .map { (type, addresses) -> URLQueryItem in
                    URLQueryItem(
                        name: type.activaParameter,
                        value: addresses.joined(separator: "|")
                    )
                }
        }
    }
    
    private let coin: BitcoinChainCoin
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder
    private let endpoint: Endpoint
    
    // MARK: - Init

    init(coin: BitcoinChainCoin,
         requestBuilder: RequestBuilder = resolve(),
         networkAdapter: NetworkAdapterAPI = resolve()) {
        self.coin = coin
        self.requestBuilder = requestBuilder
        self.endpoint = Endpoint(coin: coin)
        self.networkAdapter = networkAdapter
    }
    
    // MARK: - APIClientAPI
    
    func multiAddress<T: BitcoinChainHistoricalTransactionResponse>(for wallets: [APIWalletModel]) -> Single<BitcoinChainMultiAddressResponse<T>> {
        let parameters = Parameter.active(wallets: wallets)
        let request = requestBuilder.get(
            path: endpoint.multiaddress,
            parameters: parameters,
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }

    func balances(for wallets: [APIWalletModel]) -> Single<BitcoinChainBalanceResponse> {
        let parameters = Parameter.active(wallets: wallets)
        let request = requestBuilder.get(
            path: endpoint.balance,
            parameters: parameters,
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }
    
    func unspentOutputs(for wallets: [APIWalletModel]) -> Single<UnspentOutputsResponse> {
        let parameters = Parameter.active(wallets: wallets)
        let request = requestBuilder.post(
            path: endpoint.unspent,
            parameters: parameters,
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }
}
