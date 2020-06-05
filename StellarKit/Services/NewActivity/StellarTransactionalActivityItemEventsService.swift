//
//  StellarTransactionalActivityItemEventsService.swift
//  StellarKit
//
//  Created by Alex McGregor on 5/11/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public final class StellarTransactionalActivityItemEventsService: TransactionalActivityItemEventFetcherAPI {
    
    public typealias PageModel = PageResult<TransactionalActivityItemEvent>

    private let transactionService: StellarHistoricalTransactionService

    init(transactionService: StellarHistoricalTransactionService) {
        self.transactionService = transactionService
    }

    public init(repository: StellarWalletAccountRepositoryAPI) {
        self.transactionService = StellarHistoricalTransactionService(repository: repository)
    }
    
    public func fetchTransactionalActivityEvents(token: String?, limit: Int) -> Single<PageModel> {
        transactionService
            .fetchTransactions(token: token, size: limit)
            .map(weak: self) { (self, output) -> PageResult<TransactionalActivityItemEvent> in
                let items = output.items.map { $0.activityItemEvent }
                return PageResult(
                    hasNextPage: items.count == limit,
                    items: items
                )
        }
    }
}

fileprivate extension StellarHistoricalTransaction {
    var activityItemEvent: TransactionalActivityItemEvent {
        .init(
            identifier: identifier,
            creationDate: createdAt,
            status: .complete,
            type: direction == .debit ? .receive : .send,
            amount: amount
        )
    }
}
