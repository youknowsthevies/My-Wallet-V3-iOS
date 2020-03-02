//
//  CustodialBalanceResponse.swift
//  PlatformKit
//
//  Created by Paulo on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct CustodialBalanceResponse: Decodable {

    // MARK: - Types

    struct Balance: Decodable {
        let available: String
        let pending: String
    }

    enum CodingKeys: String, CodingKey {
        case btc = "BTC"
        case bch = "BCH"
        case eth = "ETH"
        case pax = "PAX"
        case xlm = "XLM"
    }

    // MARK: - Properties

    let btc: Balance?
    let bch: Balance?
    let eth: Balance?
    let pax: Balance?
    let xlm: Balance?

    // MARK: - Init

    init(btc: Balance?, bch: Balance?, eth: Balance?, pax: Balance?, xlm: Balance?) {
        self.btc = btc
        self.bch = bch
        self.eth = eth
        self.pax = pax
        self.xlm = xlm
    }

    // MARK: - Subscript

    subscript(currency: CryptoCurrency) -> Balance? {
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
