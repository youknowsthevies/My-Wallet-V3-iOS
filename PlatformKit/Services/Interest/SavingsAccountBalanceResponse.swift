//
//  SavingsAccountBalanceResponse.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SavingsAccountBalanceResponse: Decodable {

    // MARK: - Types

    public struct CurrencyBalance: Decodable {
        let balance: String?
    }

    enum CodingKeys: String, CodingKey {
        case btc = "BTC"
        case bch = "BCH"
        case eth = "ETH"
        case pax = "PAX"
        case xlm = "XLM"
    }

    // MARK: - Properties

    let btc: CurrencyBalance?
    let bch: CurrencyBalance?
    let eth: CurrencyBalance?
    let pax: CurrencyBalance?
    let xlm: CurrencyBalance?

    // MARK: - Init

    init(btc: CurrencyBalance?,
         bch: CurrencyBalance?,
         eth: CurrencyBalance?,
         pax: CurrencyBalance?,
         xlm: CurrencyBalance?) {
        self.btc = btc
        self.bch = bch
        self.eth = eth
        self.pax = pax
        self.xlm = xlm
    }

    // MARK: - Subscript

    subscript(currency: CryptoCurrency) -> CurrencyBalance? {
        switch currency {
        case .bitcoin:
            return btc
        case .bitcoinCash:
            return bch
        case .ethereum:
            return eth
        case .pax:
            return pax
        case .stellar:
            return xlm
        }
    }
}

