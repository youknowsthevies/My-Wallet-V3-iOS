//
//  BlockchainAccountFetcher.swift
//  PlatformKit
//
//  Created by Alex McGregor on 10/1/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift

public protocol BlockchainAccountFetching {
    var accounts: Single<[BlockchainAccount]> { get }
    func account(accountType: SingleAccountType) -> Single<BlockchainAccount>
}

public final class BlockchainAccountFetchingFactory {
    
    public static func make(for currencyType: CurrencyType) -> BlockchainAccountFetching {
        BlockchainAccountFetcher(currencyType: currencyType)
    }
}

final class BlockchainAccountFetcher: BlockchainAccountFetching {
    
    private let blockchainAccountProvider: BlockchainAccountProviding
    private let currencyType: CurrencyType
    
    init(currencyType: CurrencyType,
         blockchainAccountProvider: BlockchainAccountProviding = resolve()) {
        self.currencyType = currencyType
        self.blockchainAccountProvider = blockchainAccountProvider
    }
    
    // MARK: - BlockchainAccountFetching
    
    var accounts: Single<[BlockchainAccount]> {
        blockchainAccountProvider.accounts(for: currencyType)
    }
    
    func account(accountType: SingleAccountType) -> Single<BlockchainAccount> {
        blockchainAccountProvider
            .account(
                for: currencyType,
                accountType: accountType
            )
    }
}
