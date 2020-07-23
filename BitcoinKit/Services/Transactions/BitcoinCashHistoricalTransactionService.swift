//
//  BitcoinCashHistoricalTransactionService.swift
//  BitcoinKit
//
//  Created by Alex McGregor on 5/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public final class BitcoinCashHistoricalTransactionService: TokenizedHistoricalTransactionAPI {
    
    public typealias Model = BitcoinCashHistoricalTransaction
    public typealias PageModel = PageResult<Model>
    
    private let client: APIClientAPI
    private let bridge: BitcoinCashWalletBridgeAPI
    
    public convenience init(bridge: BitcoinCashWalletBridgeAPI) {
        self.init(with: resolve(), bridge: bridge)
    }
    
    init(with client: APIClientAPI, bridge: BitcoinCashWalletBridgeAPI) {
        self.client = client
        self.bridge = bridge
    }
    
    public func fetchTransactions(token: String?, size: Int) -> Single<PageModel> {
        bridge.defaultWallet.flatMap(weak: self) { (self, walletAccount) -> Single<PageModel> in
            self.client.bitcoinCashMultiAddress(for: walletAccount.publicKey)
                .map { $0.transactions }
                .map { PageModel(hasNextPage: false, items: $0) }
        }
    }
}

extension BitcoinCashHistoricalTransactionService: HistoricalTransactionDetailsAPI {

    private enum ServiceError: Error {
        case errorFetchingDetails
    }

    // It is not possible to fetch a specifig transaction detail from 'multiaddr' endpoints,
    //   so we fetch the first page and filter out the transaction from there.
    //   This may cause a edge case where a user opens the last transaction of the list, but
    //   in the mean time there was a new transaction added, making it 'drop' out of the first
    //   page. The fix for this is to have a properly paginated multiaddr/details endpoint.
    public func transaction(identifier: String) -> Observable<BitcoinCashHistoricalTransaction> {
        fetchTransactions(token: nil, size: 50)
            .map { $0.items }
            .map { $0.first(where: { $0.identifier == identifier }) }
            .onNil(error: ServiceError.errorFetchingDetails)
            .asObservable()
    }
}
