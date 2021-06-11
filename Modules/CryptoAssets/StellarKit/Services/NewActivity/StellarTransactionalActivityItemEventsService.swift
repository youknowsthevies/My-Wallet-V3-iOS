// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public final class StellarTransactionalActivityItemEventsService: TransactionalActivityItemEventFetcherAPI {

    public typealias PageModel = PageResult<TransactionalActivityItemEvent>

    private let transactionService: StellarHistoricalTransactionService

    init(transactionService: StellarHistoricalTransactionService) {
        self.transactionService = transactionService
    }

    public init(repository: StellarWalletAccountRepositoryAPI = resolve()) {
        self.transactionService = StellarHistoricalTransactionService(repository: repository)
    }

    public func fetchTransactionalActivityEvents(token: String?, limit: Int) -> Single<PageModel> {
        transactionService
            .fetchTransactions(token: token, size: limit)
            .catchError { (error) -> Single<StellarHistoricalTransactionService.PageModel> in
                guard let accountError = error as? StellarAccountError else { return Single.error(error) }
                guard case .noDefaultAccount = accountError else { return Single.error(accountError) }
                return Single.just(.init(hasNextPage: false, items: []))
            }
            .map(weak: self) { (_, output) -> PageResult<TransactionalActivityItemEvent> in
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
            transactionHash: transactionHash,
            creationDate: createdAt,
            status: .complete,
            type: direction == .debit ? .receive : .send,
            amount: amount
        )
    }
}
