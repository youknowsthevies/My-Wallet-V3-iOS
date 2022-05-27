// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

public enum EthereumDirection: String {
    case send
    case receive
    case transfer
}

public enum EthereumTransactionState: String, CaseIterable, Codable {
    case confirmed = "CONFIRMED"
    case pending = "PENDING"
    case replaced = "REPLACED"
}

public struct EthereumHistoricalTransaction {
    public static let requiredConfirmations: Int = 12

    public var fromAddress: EthereumAddress
    public var toAddress: EthereumAddress
    public var identifier: String
    public var direction: EthereumDirection
    public var amount: CryptoValue
    public var transactionHash: String
    public var createdAt: Date
    public var fee: CryptoValue?
    public var note: String?
    public var confirmations: Int
    public var state: EthereumTransactionState
    public let data: String?

    public init(
        identifier: String,
        fromAddress: EthereumAddress,
        toAddress: EthereumAddress,
        direction: EthereumDirection,
        amount: CryptoValue,
        transactionHash: String,
        createdAt: Date,
        fee: CryptoValue?,
        note: String?,
        confirmations: Int,
        data: String?,
        state: EthereumTransactionState
    ) {
        self.identifier = identifier
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.direction = direction
        self.amount = amount
        self.transactionHash = transactionHash
        self.createdAt = createdAt
        self.fee = fee
        self.note = note
        self.confirmations = confirmations
        self.state = state
        self.data = data
    }
}

extension EthereumHistoricalTransaction: Comparable {
    public static func < (lhs: EthereumHistoricalTransaction, rhs: EthereumHistoricalTransaction) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}

extension EthereumHistoricalTransaction: Equatable {
    public static func == (lhs: EthereumHistoricalTransaction, rhs: EthereumHistoricalTransaction) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
