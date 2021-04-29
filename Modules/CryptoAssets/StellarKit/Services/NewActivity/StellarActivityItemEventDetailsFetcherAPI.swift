// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public final class StellarActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    public typealias Model = StellarActivityItemEventDetails

    private let transactionService: StellarHistoricalTransactionService

    public convenience init(repository: StellarWalletAccountRepositoryAPI = resolve()) {
        self.init(transactionService: StellarHistoricalTransactionService(repository: repository))
    }

    init(transactionService: StellarHistoricalTransactionService) {
        self.transactionService = transactionService
    }

    public func details(for identifier: String) -> Observable<StellarActivityItemEventDetails> {
        transactionService
            .transaction(identifier: identifier)
            .map { StellarActivityItemEventDetails(transaction: $0) }
            .asObservable()
    }
}
