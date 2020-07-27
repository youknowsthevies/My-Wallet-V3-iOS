//
//  ERC20HistoricalTransaction.swift
//  ERC20Kit
//
//  Created by AlexM on 5/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import EthereumKit
import NetworkKit
import PlatformKit
import RxSwift

public struct ERC20HistoricalTransaction<Token: ERC20Token>: Decodable, Hashable, HistoricalTransaction, Tokenized {

    public typealias Address = EthereumAddress
    
    /// There's not much point to `token` in this case since
    /// for ERC20 paging we use the `wallet.transactions.count` to determine
    /// if we need to fetch additional transactions.
    public var token: String {
        transactionHash
    }
    
    public var identifier: String {
        transactionHash
    }
    public var fromAddress: EthereumAddress
    public var toAddress: EthereumAddress
    public var direction: Direction
    public var amount: CryptoValue
    public var transactionHash: String
    public var createdAt: Date
    public var fee: CryptoValue?
    public var historicalFiatValue: FiatValue?
    public var memo: String?
    
    public init(
        fromAddress: EthereumAddress,
        toAddress: EthereumAddress,
        direction: Direction,
        amount: CryptoValue,
        transactionHash: String,
        createdAt: Date,
        fee: CryptoValue? = nil,
        memo: String? = nil
    ) {
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.direction = direction
        self.amount = amount
        self.transactionHash = transactionHash
        self.createdAt = createdAt
        self.fee = fee
        self.memo = memo
    }
    
    public func make(from direction: Direction, fee: CryptoValue? = nil, memo: String? = nil) -> ERC20HistoricalTransaction<Token> {
        ERC20HistoricalTransaction<Token>(
            fromAddress: fromAddress,
            toAddress: toAddress,
            direction: direction,
            amount: amount,
            transactionHash: transactionHash,
            createdAt: createdAt,
            fee: fee,
            memo: memo
        )
    }
    
    // MARK: Decodable
    
    enum CodingKeys: String, CodingKey {
        case transactionHash
        case timestamp
        case from
        case to
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let from = try values.decode(String.self, forKey: .from)
        let to = try values.decode(String.self, forKey: .to)
        let timestampString = try values.decode(String.self, forKey: .timestamp)
        transactionHash = try values.decode(String.self, forKey: .transactionHash)
        let amountString = try values.decode(String.self, forKey: .value)
        self.amount = CryptoValue.createFromMinorValue(amountString, assetType: Token.assetType) ?? CryptoValue.zero(currency: Token.assetType)
        fromAddress = EthereumAddress(stringLiteral: from)
        toAddress = EthereumAddress(stringLiteral: to)
        if let timeSinceEpoch = Double(timestampString) {
            createdAt = Date(timeIntervalSince1970: timeSinceEpoch)
        } else {
            createdAt = Date()
        }
        
        // ⚠️ NOTE: The direction is populated when you fetch transactions
        // and the user's ETH address is passed in. That's the only way to know
        // whether or not it is a debit or credit.
        // Fees are only known when we fetch the details of the transaction.
        // the `historicalFiatValue` is only know when we fetch the details
        // of the transaction.
        direction = .debit
        fee = nil
        memo = nil
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fromAddress)
        hasher.combine(toAddress)
        hasher.combine(direction.rawValue)
        hasher.combine(amount)
        hasher.combine(transactionHash)
        hasher.combine(createdAt)
    }
    
    // MARK: Private
    
    struct ERC20TransactionDetails<T: ERC20Token>: Decodable {
        let gasPrice: BigInt
        let gasLimit: BigInt
        let gasUsed: BigInt
        let success: Bool
        let data: Data?

        fileprivate var fee: CryptoValue {
            let amount = gasUsed * gasPrice
            return CryptoValue.createFromMinorValue(amount, assetType: .ethereum)
        }

        // MARK: Decodable
        
        enum CodingKeys: String, CodingKey {
            case gasPrice
            case gasLimit
            case gasUsed
            case success
            case data
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let limit = try values.decode(String.self, forKey: .gasLimit)
            let price = try values.decode(String.self, forKey: .gasPrice)
            let used = try values.decode(String.self, forKey: .gasUsed)
            let dataValue = try values.decode(String.self, forKey: .data)
            success = try values.decode(Bool.self, forKey: .success)
            data = dataValue.data(using: .utf8)
            gasPrice = BigInt(stringLiteral: price)
            gasLimit = BigInt(stringLiteral: limit)
            gasUsed = BigInt(stringLiteral: used)
        }
    }
}
