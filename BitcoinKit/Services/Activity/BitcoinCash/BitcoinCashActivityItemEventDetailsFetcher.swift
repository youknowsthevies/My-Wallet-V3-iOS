//
//  BitcoinActivityItemEventDetailsFetcher.swift
//  BitcoinKit
//
//  Created by Paulo on 26/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

public final class BitcoinCashActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    public typealias Model = BitcoinCashActivityItemEventDetails

    private let transactionService: BitcoinCashHistoricalTransactionService

    public init(transactionService: BitcoinCashHistoricalTransactionService = resolve()) {
        self.transactionService = transactionService
    }

    public func details(for identifier: String) -> Observable<BitcoinCashActivityItemEventDetails> {
        transactionService
            .transaction(identifier: identifier)
            .map { BitcoinCashActivityItemEventDetails(transaction: $0) }
    }
}
