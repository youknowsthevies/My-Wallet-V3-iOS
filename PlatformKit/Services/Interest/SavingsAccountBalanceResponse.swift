//
//  SavingsAccountBalanceResponse.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SavingsAccountBalanceResponse: Decodable {

    public static let empty = SavingsAccountBalanceResponse()

    // MARK: - Types

    public struct Details: Decodable {
        let balance: String?
    }

    // MARK: - Properties

    private let balances: [String: Details]

    // MARK: - Init

    private init() {
        balances = [:]
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        balances = try container.decode([String: Details].self)
    }

    // MARK: - Subscript

    subscript(currency: CryptoCurrency) -> Details? {
        balances[currency.rawValue]
    }
}

