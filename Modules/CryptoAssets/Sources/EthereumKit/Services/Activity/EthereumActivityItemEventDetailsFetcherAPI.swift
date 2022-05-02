// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxSwift

final class EthereumActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    typealias Model = EthereumActivityItemEventDetails

    private let transactionService: HistoricalTransactionsRepositoryAPI

    init(transactionService: HistoricalTransactionsRepositoryAPI = resolve()) {
        self.transactionService = transactionService
    }

    func details(
        for identifier: String,
        cryptoCurrency: CryptoCurrency
    ) -> Observable<EthereumActivityItemEventDetails> {
        transactionService
            .transaction(identifier: identifier)
            .map(EthereumActivityItemEventDetails.init(transaction:))
            .asObservable()
    }
}
