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
        guard let network: EVMNetwork = cryptoCurrency.assetModel.kind.evmNetwork else {
            fatalError("EthereumActivityItemEventDetailsFetcher should only be used for EVM currencies.")
        }
        return transactionService
            .transaction(network: network, identifier: identifier)
            .map(EthereumActivityItemEventDetails.init(transaction:))
            .asObservable()
    }
}
