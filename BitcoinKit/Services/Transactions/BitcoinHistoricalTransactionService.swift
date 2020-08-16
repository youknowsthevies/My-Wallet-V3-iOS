//
//  BitcoinHistoricalTransactionService.swift
//  BitcoinKit
//
//  Created by Alex McGregor on 5/18/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public final class BitcoinHistoricalTransactionService: TokenizedHistoricalTransactionAPI {
    
    public typealias Model = BitcoinHistoricalTransaction
    public typealias PageModel = PageResult<Model>
    
    private let client: APIClientAPI
    private let repository: BitcoinWalletAccountRepository
    
    public convenience init(repository: BitcoinWalletAccountRepository) {
        self.init(with: resolve(), repository: repository)
    }
    
    init(with client: APIClientAPI, repository: BitcoinWalletAccountRepository) {
        self.client = client
        self.repository = repository
    }
    
    public func fetchTransactions(token: String?, size: Int) -> Single<PageModel> {
        repository.activeAccounts
            .map { accounts in accounts.map(\.publicKey) }
            .flatMap(weak: self) { (self, addresses) -> Single<PageModel> in
                self.client.bitcoinMultiAddress(for: addresses)
                    .map(\.transactions)
                    .map { PageModel(hasNextPage: false, items: $0) }
        }
    }
}

extension BitcoinHistoricalTransactionService: HistoricalTransactionDetailsAPI {

    private enum ServiceError: Error {
        case errorFetchingDetails
    }

    // It is not possible to fetch a specifig transaction detail from 'multiaddr' endpoints,
    //   so we fetch the first page and filter out the transaction from there.
    //   This may cause a edge case where a user opens the last transaction of the list, but
    //   in the mean time there was a new transaction added, making it 'drop' out of the first
    //   page. The fix for this is to have a properly paginated multiaddr/details endpoint.
    public func transaction(identifier: String) -> Observable<BitcoinHistoricalTransaction> {
        fetchTransactions(token: nil, size: 50)
            .map { $0.items }
            .map { $0.first(where: { $0.identifier == identifier }) }
            .onNil(error: ServiceError.errorFetchingDetails)
            .asObservable()
    }
}
