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
import DIKit

enum APIClientError: Error {
    case unknown
}

protocol APIClientAPI {
    func unspentOutputs(addresses: [String]) -> Single<UnspentOutputsResponse>
    func bitcoinMultiAddress(for addresses: [String]) -> Single<BitcoinMultiAddressResponse>
    func bitcoinCashMultiAddress(for address: String) -> Single<BitcoinCashMultiAddressResponse>
    func balances(for addresses: [String]) -> Single<BitcoinBalanceResponse>
}

final class APIClient: APIClientAPI {
    
    private struct Endpoint {
        
        struct Bitcoin {
            static let base = [ "btc" ]
            static let multiaddress = base + [ "multiaddr" ]
            static let unspentOutputs = base + [ "unspent" ]
            static let balance = base + [ "balance" ]
        }
        
        struct BitcoinCash {
            static let base = [ "bch" ]
            static let multiaddress = base + [ "multiaddr" ]
        }
    }

    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder: RequestBuilder
    
    // MARK: - Init

    init(communicator: NetworkCommunicatorAPI = resolve(),
         requestBuilder: RequestBuilder = resolve()) {
        self.communicator = communicator
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - APIClientAPI
    
    func unspentOutputs(addresses: [String]) -> Single<UnspentOutputsResponse> {
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
    
    func bitcoinCashMultiAddress(for address: String) -> Single<BitcoinCashMultiAddressResponse> {
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
    
    func bitcoinMultiAddress(for addresses: [String]) -> Single<BitcoinMultiAddressResponse> {
        let value = addresses.joined(separator: "|")
        let parameters = [
            URLQueryItem(
                name: "active",
                value: value
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
    
    func balances(for addresses: [String]) -> Single<BitcoinBalanceResponse> {
        let addresses = addresses.joined(separator: "|")
        let parameters = [
            URLQueryItem(
                name: "active",
                value: "\(addresses)"
            )
        ]
        let request = requestBuilder.get(
            path: Endpoint.Bitcoin.balance,
            parameters: parameters,
            recordErrors: true
        )!
        return communicator.perform(request: request)
    }
}
