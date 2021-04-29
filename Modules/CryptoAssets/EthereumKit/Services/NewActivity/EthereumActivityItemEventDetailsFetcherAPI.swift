// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public final class EthereumActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    public typealias Model = EthereumActivityItemEventDetails

    private let transactionService: EthereumHistoricalTransactionService

    public init(transactionService: EthereumHistoricalTransactionService = resolve()) {
        self.transactionService = transactionService
    }

    public func details(for identifier: String) -> Observable<EthereumActivityItemEventDetails> {
        transactionService
            .transaction(identifier: identifier)
            .map { EthereumActivityItemEventDetails(transaction: $0) }
    }
}
