// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// An `Event` has a `Status` indicating
/// whether it is complete or not, a `type`,
/// and an amount associated with the `Event`.
public struct TransactionalActivityItemEvent: Tokenized {

    public enum EventStatus {
        public struct Confirmations {
            /// How many confirmations have taken place
            public let current: Int
            /// The total number of confirmations required
            public let total: Int

            public init(current: Int, total: Int) {
                self.current = current
                self.total = total
            }
        }

        /// The event is pending confirmation
        case pending(confirmations: Confirmations)
        /// The event has completed
        case complete
    }

    public enum EventType {
        /// Send transaction
        case send
        /// Transaction was received
        case receive
    }

    public let creationDate: Date
    public let identifier: String
    public let status: EventStatus
    public let type: EventType
    public let amount: CryptoValue

    public var currency: CryptoCurrency {
        amount.currencyType
    }

    public var token: String {
        identifier
    }

    public init(identifier: String,
                creationDate: Date,
                status: EventStatus,
                type: EventType,
                amount: CryptoValue) {
        self.creationDate = creationDate
        self.identifier = identifier
        self.status = status
        self.type = type
        self.amount = amount
    }
}

extension TransactionalActivityItemEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
