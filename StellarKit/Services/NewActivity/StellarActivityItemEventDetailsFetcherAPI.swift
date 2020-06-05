//
//  StellarActivityItemEventDetailsFetcherAPI.swift
//  StellarKit
//
//  Created by Paulo on 21/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public final class StellarActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    public typealias Model = StellarActivityItemEventDetails

    private let transactionService: StellarHistoricalTransactionService

    public convenience init(repository: StellarWalletAccountRepositoryAPI) {
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
