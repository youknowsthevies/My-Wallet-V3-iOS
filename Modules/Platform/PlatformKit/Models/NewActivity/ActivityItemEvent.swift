// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum ActivityItemEvent: Tokenized {

    case swap(SwapActivityItemEvent)
    // Send/Receive
    case transactional(TransactionalActivityItemEvent)
    // Buy
    case buySell(BuySellActivityItemEvent)
    // Fiat
    case fiat(FiatActivityItemEvent)

    /// The `Status` of an activity item.
    public enum EventStatus {
        
        public struct Confirmations {
            /// How many confirmations have taken place
            public let current: Int
            /// The total number of confirmations required
            public let total: Int
        }
        
        public enum ProductEventStatus {
            case swap(SwapActivityItemEvent.EventStatus)
            case buySell(BuySellActivityItemEvent.EventStatus)
            case fiat(FiatActivityItemEvent.EventStatus)
        }
        
        /// The event is pending confirmation
        case pending(confirmations: Confirmations)
        /// The event has completed
        case complete
        /// The status of a product related event
        /// including `Swap`, `Buy`, and `Sell`.
        case product(ProductEventStatus)
    }
    
    public var token: String {
        switch self {
        case .buySell(let event):
            return event.identifier
        case .swap(let event):
            return event.identifier
        case .transactional(let event):
            return event.identifier
        case .fiat(let event):
            return event.identifier
        }
    }
    
    public var creationDate: Date {
        switch self {
        case .buySell(let event):
            return event.creationDate
        case .swap(let swap):
            return swap.date
        case .transactional(let transaction):
            return transaction.creationDate
        case .fiat(let fiat):
            return fiat.date
        }
    }
}

extension ActivityItemEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .buySell(let event):
            hasher.combine("buySell")
            hasher.combine(event)
        case .swap(let event):
            hasher.combine("swap")
            hasher.combine(event)
        case .transactional(let event):
            hasher.combine("transactional")
            hasher.combine(event)
        case .fiat(let event):
            hasher.combine("fiat")
            hasher.combine(event)
        }
    }
}

extension ActivityItemEvent {
    
    public var amount: MoneyValue {
        switch self {
        case .buySell(let event):
            return event.outputValue
        case .swap(let event):
            return event.amounts.deposit
        case .transactional(let event):
            return .init(cryptoValue: event.amount)
        case .fiat(let event):
            return .init(fiatValue: event.fiatValue)
        }
    }
    
    public var identifier: String {
        switch self {
        case .buySell(let event):
            return event.identifier
        case .swap(let event):
            return event.identifier
        case .transactional(let event):
            return event.identifier
        case .fiat(let event):
            return event.identifier
        }
    }
    
    public var status: EventStatus {
        switch self {
        case .buySell(let event):
            return .product(.buySell(event.status))
        case .swap(let event):
            return .product(.swap(event.status))
        case .transactional(let event):
            switch event.status {
            case .complete:
                return .complete
            case .pending(confirmations: let confirmations):
                return .pending(confirmations: .init(
                    current: confirmations.current,
                    total: confirmations.total
                    )
                )
            }
        case .fiat(let event):
            return .product(.fiat(event.status))
        }
    }
}

extension ActivityItemEvent: Equatable {
    public static func == (lhs: ActivityItemEvent, rhs: ActivityItemEvent) -> Bool {
        switch (lhs, rhs) {
        case (.swap(let left), .swap(let right)):
            return left == right
        case (.transactional(let left), .transactional(let right)):
            return left == right
        case (.buySell(let left), .buySell(let right)):
            return left == right
        case (.fiat(let left), .fiat(let right)):
            return left == right
        default:
            return false
        }
    }
}
