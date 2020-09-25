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

public final class BitcoinActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    public typealias Model = BitcoinActivityItemEventDetails

    private let transactionService: BitcoinHistoricalTransactionService

    public init(transactionService: BitcoinHistoricalTransactionService = resolve()) {
        self.transactionService = transactionService
    }

    public func details(for identifier: String) -> Observable<BitcoinActivityItemEventDetails> {
        transactionService
            .transaction(identifier: identifier)
            .map { BitcoinActivityItemEventDetails(transaction: $0) }
    }
}
