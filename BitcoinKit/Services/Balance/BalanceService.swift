//
//  BalanceService.swift
//  BitcoinKit
//
//  Created by Paulo on 12/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxRelay
import RxSwift

protocol BalanceServiceAPI {
    func bitcoinBalance(for address: String) -> Single<CryptoValue>
    func bitcoinBalances(for addresses: [String]) -> Single<CryptoValue>
    func bitcoinCashBalance(for address: String) -> Single<CryptoValue>
    func bitcoinCashBalances(for addresses: [String]) -> Single<CryptoValue>
}

final class BalanceService: BalanceServiceAPI {

    func bitcoinBalance(for address: String) -> Single<CryptoValue> {
        bitcoinBalances(for: [address])
    }

    func bitcoinBalances(for addresses: [String]) -> Single<CryptoValue> {
        client.bitcoinBalances(for: addresses)
            .map { BitcoinBalances(response: $0, cryptoCurrency: .bitcoin) }
            .map(\.total)
    }

    func bitcoinCashBalance(for address: String) -> Single<CryptoValue> {
        bitcoinCashBalances(for: [address])
    }

    func bitcoinCashBalances(for addresses: [String]) -> Single<CryptoValue> {
        client.bitcoinCashBalances(for: addresses)
            .map { BitcoinBalances(response: $0, cryptoCurrency: .bitcoinCash) }
            .map(\.total)
    }

    private let client: APIClientAPI

    init(client: APIClientAPI = resolve()) {
        self.client = client
    }

}

fileprivate struct BitcoinBalances {

    let total: CryptoValue

    private let balances: [String: CryptoValue]

    init(response: BitcoinBalanceResponse, cryptoCurrency: CryptoCurrency) {
        precondition(cryptoCurrency == .bitcoin || cryptoCurrency == .bitcoinCash)
        balances = response.compactMapValues { item -> CryptoValue? in
            CryptoValue(minor: "\(item.finalBalance)", cryptoCurrency: cryptoCurrency)
        }
        total = (try? balances
            .values
            .reduce(CryptoValue.zero(currency: cryptoCurrency), +)) ?? CryptoValue.zero(currency: cryptoCurrency)
    }

    subscript(account: BitcoinWalletAccount) -> CryptoValue? {
        balances[account.publicKey]
    }
}
