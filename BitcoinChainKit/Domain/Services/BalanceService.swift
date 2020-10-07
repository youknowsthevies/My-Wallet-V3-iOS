//
//  BalanceService.swift
//  BitcoinChainKit
//
//  Created by Jack Pooley on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

public protocol BalanceServiceAPI {
    
    func balance(for address: String) -> Single<CryptoValue>
    
    func balances(for addresses: [String]) -> Single<CryptoValue>
}

final class BalanceService: BalanceServiceAPI {
    
    private let client: APIClientAPI
    private let coin: BitcoinChainCoin
    
    convenience init(coin: BitcoinChainCoin) {
        self.init(client: resolve(tag: coin), coin: coin)
    }

    init(client: APIClientAPI, coin: BitcoinChainCoin) {
        self.client = client
        self.coin = coin
    }
    
    // MARK: - BalanceServiceAPI
    
    func balance(for address: String) -> Single<CryptoValue> {
        balances(for: [address])
    }

    func balances(for addresses: [String]) -> Single<CryptoValue> {
        client.balances(for: addresses)
            .map(weak: self) { (self, response) in
                BitcoinChainBalances(response: response, coin: self.coin)
            }
            .map(\.total)
    }
}

fileprivate struct BitcoinChainBalances {

    let total: CryptoValue

    private let balances: [String: CryptoValue]

    init(response: BitcoinChainBalanceResponse, coin: BitcoinChainCoin) {
        let cryptoCurrency = coin.cryptoCurrency
        balances = response.compactMapValues { item -> CryptoValue? in
            CryptoValue.create(minor: "\(item.finalBalance)", currency: cryptoCurrency)
        }
        total = (try? balances
            .values
            .reduce(CryptoValue.zero(currency: cryptoCurrency), +)) ?? CryptoValue.zero(currency: cryptoCurrency)
    }
}
