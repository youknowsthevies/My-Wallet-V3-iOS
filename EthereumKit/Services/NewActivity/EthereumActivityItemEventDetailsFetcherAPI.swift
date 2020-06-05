//
//  EthereumActivityItemEventDetailsFetcherAPI.swift
//  EthereumKit
//
//  Created by Paulo on 21/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public final class EthereumActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    public typealias Model = EthereumActivityItemEventDetails

    private let transactionService: EthereumHistoricalTransactionService

    public init(transactionService: EthereumHistoricalTransactionService) {
        self.transactionService = transactionService
    }

    public func details(for identifier: String) -> Observable<EthereumActivityItemEventDetails> {
        transactionService
            .transaction(identifier: identifier)
            .map { EthereumActivityItemEventDetails(transaction: $0) }
    }
}
