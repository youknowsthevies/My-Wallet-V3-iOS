//
//  BitcoinTransactionalActivityItemEventsService.swift
//  BitcoinKit
//
//  Created by Alex McGregor on 5/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public final class BitcoinTransactionalActivityItemEventsService: TransactionalActivityItemEventFetcherAPI {
    
    public typealias PageModel = PageResult<TransactionalActivityItemEvent>
    
    private let transactionsService: BitcoinHistoricalTransactionService
    
    public init(transactionsService: BitcoinHistoricalTransactionService) {
        self.transactionsService = transactionsService
    }
    
    public func fetchTransactionalActivityEvents(token: String?, limit: Int) -> Single<PageModel> {
        transactionsService
            .fetchTransactions(token: nil, size: 50)
            .map(weak: self) { (self, output) -> PageResult<TransactionalActivityItemEvent> in
                let items = output.items.map { $0.activityItemEvent }
                return PageResult(
                    hasNextPage: items.count == limit,
                    items: items
                )
            }
    }
}

extension BitcoinHistoricalTransaction {
    fileprivate var activityItemEvent: TransactionalActivityItemEvent {
        var status: TransactionalActivityItemEvent.EventStatus
        switch isConfirmed {
        case true:
            status = .complete
        case false:
            status = .pending(
                confirmations: .init(
                    current: confirmations,
                    total: BitcoinHistoricalTransaction.requiredConfirmations
                )
            )
        }
        return .init(
            identifier: identifier,
            creationDate: createdAt,
            status: status,
            type: direction == .debit ? .receive : .send,
            amount: amount
        )
    }
}
