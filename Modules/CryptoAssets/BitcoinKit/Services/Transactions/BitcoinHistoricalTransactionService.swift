// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import PlatformKit
import RxSwift
import ToolKit

public final class BitcoinHistoricalTransactionService: TokenizedHistoricalTransactionAPI {

    public typealias Model = BitcoinHistoricalTransaction
    public typealias PageModel = PageResult<Model>

    private let client: APIClientAPI
    private let repository: BitcoinWalletAccountRepository

    init(with client: APIClientAPI = resolve(), repository: BitcoinWalletAccountRepository = resolve()) {
        self.client = client
        self.repository = repository
    }
    
    public func fetchTransactions(token: String?, size: Int) -> Single<PageModel> {
        repository.activeAccounts
            .map { accounts in
                accounts
                    .map(\.publicKeys.xpubs)
                    .flatMap { $0 }
            }
            .flatMap(weak: self) { (self, addresses) -> Single<PageModel> in
                self.client.multiAddress(for: addresses)
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
