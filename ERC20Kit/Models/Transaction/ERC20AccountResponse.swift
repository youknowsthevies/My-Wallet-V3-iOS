//
//  ERC20AccountResponse.swift
//  ERC20Kit
//
//  Created by AlexM on 5/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import PlatformKit
import EthereumKit
import BigInt
import RxSwift

public struct ERC20AccountResponse<Token: ERC20Token>: Decodable, Tokenized {

    public let currentPage: Int
    public let fromAddress: EthereumAddress
    public let pageSize: Int
    public let transactions: [ERC20HistoricalTransaction<Token>]
    let balance: String
    let decimals: Int
    let tokenHash: String

    public var token: String {
        String(currentPage)
    }

    // MARK: Decodable

    enum CodingKeys: String, CodingKey {
        case balance
        case decimals
        case fromAddress = "accountHash"
        case page
        case size
        case tokenHash
        case transactions = "transfers"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let from = try values.decode(String.self, forKey: .fromAddress)
        fromAddress = EthereumAddress(stringLiteral: from)
        transactions = try values.decode([ERC20HistoricalTransaction<Token>].self, forKey: .transactions)
        let page = try values.decode(String.self, forKey: .page)
        currentPage = Int(page) ?? 0
        pageSize = try values.decode(Int.self, forKey: .size)
        tokenHash = try values.decode(String.self, forKey: .tokenHash)
        balance = try values.decode(String.self, forKey: .balance)
        decimals = try values.decode(Int.self, forKey: .decimals)
    }

    public init(
        currentPage: Int,
        fromAddress: EthereumAddress,
        pageSize: Int,
        transactions: [ERC20HistoricalTransaction<Token>],
        balance: String,
        decimals: Int,
        tokenHash: String
    ) {
        self.currentPage = currentPage
        self.fromAddress = fromAddress
        self.pageSize = pageSize
        self.transactions = transactions
        self.balance = balance
        self.decimals = decimals
        self.tokenHash = tokenHash
    }
}
