// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public final class EthereumTransactionalActivityItemEventsService: TransactionalActivityItemEventFetcherAPI {

    public typealias PageModel = PageResult<TransactionalActivityItemEvent>

    private let transactionsService: EthereumHistoricalTransactionService

    public init(transactionsService: EthereumHistoricalTransactionService = resolve()) {
        self.transactionsService = transactionsService
    }

    public func fetchTransactionalActivityEvents(token: String?, limit: Int) -> Single<PageModel> {
        // TODO: Pagination for ETH Transactions
        transactionsService
            .fetchTransactions()
            .map(weak: self) { (_, output) -> PageResult<TransactionalActivityItemEvent> in
               let items = output.map { $0.activityItemEvent }
                return PageResult(
                    hasNextPage: items.count == limit,
                    items: items
                )
            }
    }
}

fileprivate extension EthereumHistoricalTransaction {
    var activityItemEvent: TransactionalActivityItemEvent {
        var status: TransactionalActivityItemEvent.EventStatus
        switch state {
        case .confirmed,
             .replaced:
            status = .complete
        case .pending:
            status = .pending(
                confirmations: .init(
                    current: confirmations,
                    total: EthereumHistoricalTransaction.requiredConfirmations
                )
            )
        }
        return .init(
            identifier: identifier,
            transactionHash: transactionHash,
            creationDate: createdAt,
            status: status,
            type: direction == .debit ? .receive : .send,
            amount: amount
        )
    }
}
