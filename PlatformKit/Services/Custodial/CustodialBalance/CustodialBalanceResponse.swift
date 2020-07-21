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
    }

    // MARK: - Properties

    let balances: [String: Balance]

    // MARK: - Init

    init(balances: [String: Balance]) {
        self.balances = balances
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        balances = try container.decode([String: Balance].self)
    }

    // MARK: - Subscript

    subscript(currencyCode: String) -> Balance? {
        balances[currencyCode]
    }
}
