// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

public struct EVMHistoricalTransaction: Equatable {

    public struct Confirmation: Equatable {
        public let needConfirmation: Bool
        public let confirmations: Int
        public let requiredConfirmations: Int
        public let factor: Float
        public let status: EthereumTransactionState

        public init(
            needConfirmation: Bool,
            confirmations: Int,
            requiredConfirmations: Int,
            factor: Float,
            status: EthereumTransactionState
        ) {
            self.needConfirmation = needConfirmation
            self.confirmations = confirmations
            self.requiredConfirmations = requiredConfirmations
            self.factor = factor
            self.status = status
        }
    }

    public let amount: CryptoValue
    public let confirmation: Confirmation
    public let createdAt: Date
    public let direction: EthereumDirection
    public let fee: CryptoValue
    public let from: EthereumAddress
    public let identifier: String
    public let to: EthereumAddress

    public init(
        amount: CryptoValue,
        confirmation: EVMHistoricalTransaction.Confirmation,
        createdAt: Date,
        direction: EthereumDirection,
        fee: CryptoValue,
        from: EthereumAddress,
        identifier: String,
        to: EthereumAddress
    ) {
        self.amount = amount
        self.confirmation = confirmation
        self.createdAt = createdAt
        self.direction = direction
        self.fee = fee
        self.from = from
        self.identifier = identifier
        self.to = to
    }
}

extension EVMHistoricalTransaction {
    public func activityItemEvent(sourceIdentifier: String) -> TransactionalActivityItemEvent {
        TransactionalActivityItemEvent(
            identifier: identifier,
            transactionHash: identifier,
            sourceIdentifier: sourceIdentifier,
            creationDate: createdAt,
            status: .complete,
            type: direction == .receive ? .receive : .send,
            amount: amount,
            fee: fee
        )
    }
}
