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
        case eth = "ETH"
    }

    // MARK: - Properties

    let btc: Balance?
    let eth: Balance?

    // MARK: - Init

    init(btc: Balance?, eth: Balance?) {
        self.btc = btc
        self.eth = eth
    }

    // MARK: - Subscript

    subscript(currency: CryptoCurrency) -> Balance? {
        switch currency {
        case .bitcoin:
            return btc
        case .ethereum:
            return eth
        default:
            return nil
        }
    }
}
