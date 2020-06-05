//
//  NetworkClient.swift
//  BitcoinKit
//
//  Created by Jack on 08/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import PlatformKit
import RxSwift

enum APIClientError: Error {
    case unknown
}

public protocol APIClientAPI {
    func unspentOutputs(addresses: [String]) -> Single<UnspentOutputsResponse>
    func bitcoinMultiAddress(for address: String) -> Single<BitcoinMultiAddressResponse>
    func bitcoinCashMultiAddress(for address: String) -> Single<BitcoinCashMultiAddressResponse>
}

public final class APIClient: APIClientAPI {
    
    private struct Endpoint {
        
        struct Bitcoin {
            static let base: [String] = [ "btc" ]
            static let multiaddress: [String] = base + [ "multiaddr" ]
            static let unspentOutputs: [String] = base + [ "unspent" ]
        }
        
        struct BitcoinCash {
            static let base: [String] = [ "bch" ]
            static let multiaddress: [String] = base + [ "multiaddr" ]
        }
    }

    private let communicator: NetworkCommunicatorAPI
    private let config: Network.Config
    private let requestBuilder: RequestBuilder
    
    // MARK: - Init

    public init(communicator: NetworkCommunicatorAPI = Network.Dependencies.default.communicator,
                config: Network.Config = Network.Dependencies.default.blockchainAPIConfig) {
        self.communicator = communicator
        self.config = config
        self.requestBuilder = RequestBuilder(networkConfig: config)
    }
    
    // MARK: - APIClientAPI
    
    public func unspentOutputs(addresses: [String]) -> Single<UnspentOutputsResponse> {
        let parameters = [
            URLQueryItem(
                name: "active",
                value: addresses.joined(separator: "|")
            )
        ]
        guard let request = requestBuilder.post(
            path: Endpoint.Bitcoin.unspentOutputs,
            parameters: parameters,
            recordErrors: true
        ) else {
            return Single.error(RequestBuilder.Error.buildingRequest)
        }
        return communicator.perform(request: request)
    }
    
    public func bitcoinCashMultiAddress(for address: String) -> Single<BitcoinCashMultiAddressResponse> {
        let parameters = [
            URLQueryItem(
                name: "active",
                value: address
            )
        ]
        
        guard let request = requestBuilder.get(
            path: Endpoint.BitcoinCash.multiaddress,
            parameters: parameters,
            recordErrors: true
        ) else {
            return Single.error(RequestBuilder.Error.buildingRequest)
        }
        return communicator.perform(request: request)
    }
    
    public func bitcoinMultiAddress(for address: String) -> Single<BitcoinMultiAddressResponse> {
        let parameters = [
            URLQueryItem(
                name: "active",
                value: address
            )
        ]
        
        guard let request = requestBuilder.get(
            path: Endpoint.Bitcoin.multiaddress,
            parameters: parameters,
            recordErrors: true
        ) else {
            return Single.error(RequestBuilder.Error.buildingRequest)
        }
        return communicator.perform(request: request)
    }
}
