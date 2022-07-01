// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation

protocol TransactionClientAPI {

    func fetchTransactions(
        _ params: TransactionsParams?
    ) -> AnyPublisher<[Card.Transaction], NabuNetworkError>
}

extension TransactionClientAPI {

    func fetchTransactions() -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        fetchTransactions(nil)
    }
}

struct TransactionsParams {

    let cardId: String?
    let types: [Card.Transaction.TransactionType]?
    let from: Date?
    let to: Date?
    let toId: String?
    let fromId: String?
    let limit: Int?

    enum CodingKeys: String, CodingKey {
        case cardId
        case types
        case toId
        case fromId
        case limit
        case from
        case to
    }
}
