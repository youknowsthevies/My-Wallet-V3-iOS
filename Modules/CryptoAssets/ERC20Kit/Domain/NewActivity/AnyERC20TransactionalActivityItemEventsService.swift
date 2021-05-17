// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

public final class AnyERC20TransactionalActivityItemEventsService<Token: ERC20Token>: TransactionalActivityItemEventFetcherAPI {

    public typealias PageModel = PageResult<TransactionalActivityItemEvent>

    private let transactionsService: AnyERC20HistoricalTransactionService<Token>

    public init(transactionsService: AnyERC20HistoricalTransactionService<Token>) {
        self.transactionsService = transactionsService
    }

    public func fetchTransactionalActivityEvents(token: String?, limit: Int) -> Single<PageModel> {
        transactionsService
            .fetchTransactions(token: nil, size: limit)
            .map(weak: self) { (_, output) -> PageResult<TransactionalActivityItemEvent> in
                let items = output.items.map { $0.activityItemEvent }
                return PageResult(
                    hasNextPage: items.count == limit,
                    items: items
                )
            }
    }
}

fileprivate extension ERC20HistoricalTransaction {
    var activityItemEvent: TransactionalActivityItemEvent {
        // TODO: Confirmation Status
        .init(
            identifier: identifier,
            creationDate: createdAt,
            status: .complete,
            type: direction == .debit ? .receive : .send,
            amount: amount
        )
    }
}
