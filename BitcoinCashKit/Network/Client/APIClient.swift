//
//  APIClient.swift
//  BitcoinCashKit
//
//  Created by Jack Pooley on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import DIKit
import NetworkKit
import PlatformKit
import RxSwift

enum APIClientError: Error {
    case unknown
}

protocol APIClientAPI {
    
    func multiAddress(for addresses: [String]) -> Single<BitcoinCashMultiAddressResponse>
    func balances(for addresses: [String]) -> Single<BitcoinCashBalanceResponse>
}

final class APIClient: APIClientAPI {
    
    private let client: BitcoinChainKit.APIClientAPI
    
    // MARK: - Init

    init(client: BitcoinChainKit.APIClientAPI = resolve(tag: BitcoinChainCoin.bitcoinCash)) {
        self.client = client
    }
    
    // MARK: - APIClientAPI
    
    func multiAddress(for addresses: [String]) -> Single<BitcoinCashMultiAddressResponse> {
        client.multiAddress(for: addresses)
    }

    func balances(for addresses: [String]) -> Single<BitcoinCashBalanceResponse> {
        client.balances(for: addresses)
    }
}
