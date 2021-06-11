// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public final class ERC20TransactionalActivityItemEventsService: TransactionalActivityItemEventFetcherAPI {

    public typealias PageModel = PageResult<TransactionalActivityItemEvent>

    private let transactionsService: ERC20HistoricalTransactionServiceAPI
    private let cryptoCurrency: CryptoCurrency

    public init(
        transactionsService: ERC20HistoricalTransactionServiceAPI = resolve(),
        cryptoCurrency: CryptoCurrency
    ) {
        self.transactionsService = transactionsService
        self.cryptoCurrency = cryptoCurrency
        assert(cryptoCurrency.isERC20, "ERC20TransactionalActivityItemEventsService should only be used with ERC20 CryptoCurrency")
    }

    public func fetchTransactionalActivityEvents(token: String?, limit: Int) -> Single<PageModel> {
        transactionsService
            .transactions(cryptoCurrency: cryptoCurrency, token: nil, size: limit)
            .map { output -> PageResult<TransactionalActivityItemEvent> in
                PageResult(
                    hasNextPage: output.hasNextPage,
                    items: output.items.map { $0.activityItemEvent }
                )
            }
    }
}

fileprivate extension ERC20HistoricalTransaction {
    var activityItemEvent: TransactionalActivityItemEvent {
        // TODO: Confirmation Status
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
