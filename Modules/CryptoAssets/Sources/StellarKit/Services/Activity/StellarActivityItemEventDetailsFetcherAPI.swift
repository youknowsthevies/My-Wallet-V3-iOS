// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxSwift

final class StellarActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    typealias Model = StellarActivityItemEventDetails

    private let repository: StellarWalletAccountRepositoryAPI
    private let operationsService: StellarHistoricalTransactionServiceAPI

    init(
        repository: StellarWalletAccountRepositoryAPI = resolve(),
        operationsService: StellarHistoricalTransactionServiceAPI = resolve()
    ) {
        self.repository = repository
        self.operationsService = operationsService
    }

    func details(
        for identifier: String,
        cryptoCurrency: CryptoCurrency
    ) -> Observable<StellarActivityItemEventDetails> {
        repository.defaultAccount
            .asObservable()
            .flatMap(weak: self) { (self, account) -> Observable<StellarActivityItemEventDetails> in
                guard let accountID = account?.publicKey else {
                    return .error(StellarAccountError.noDefaultAccount)
                }
                return self.details(operationID: identifier, accountID: accountID)
            }
    }

    private func details(operationID: String, accountID: String) -> Observable<StellarActivityItemEventDetails> {
        operationsService
            .transaction(accountID: accountID, operationID: operationID)
            .map(StellarActivityItemEventDetails.init)
            .asObservable()
    }
}
