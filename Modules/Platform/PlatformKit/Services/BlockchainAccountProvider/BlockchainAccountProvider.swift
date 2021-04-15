//
//  BlockchainAccountProvider.swift
//  PlatformKit
//
//  Created by Alex McGregor on 9/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift

public protocol BlockchainAccountProviding: AnyObject {
    func accounts(for currency: CurrencyType) -> Single<[BlockchainAccount]>
    func accounts(for currency: CurrencyType, accountType: SingleAccountType) -> Single<[BlockchainAccount]>
    func accounts(accountType: SingleAccountType) -> Single<[BlockchainAccount]>
    func account(for currency: CurrencyType, accountType: SingleAccountType) -> Single<BlockchainAccount>
}

public enum BlockchainAccountProvidingError: Error {
    case doesNotExist
}

final class BlockchainAccountProvider: BlockchainAccountProviding {
    private let coincore: Coincore
    
    init(coincore: Coincore = resolve()) {
        self.coincore = coincore
    }
    
    func accounts(for currency: CurrencyType) -> Single<[BlockchainAccount]> {
        coincore
            .allAccounts
            .map { $0.accounts.filter { $0.currencyType == currency } }
    }
    
    func accounts(accountType: SingleAccountType) -> Single<[BlockchainAccount]> {
        coincore
            .allAccounts
            .map { $0.accounts.filter { $0.accountType == accountType } }
    }
    
    func accounts(for currency: CurrencyType, accountType: SingleAccountType) -> Single<[BlockchainAccount]> {
        coincore
            .allAccounts
            .map { $0.accounts.filter { $0.currencyType == currency } }
            .map { $0.filter { $0.accountType == accountType } }
    }
    
    func account(for currency: CurrencyType, accountType: SingleAccountType) -> Single<BlockchainAccount> {
        coincore
            .allAccounts
            .map { $0.accounts.filter { $0.currencyType == currency } }
            .map { $0.filter { $0.accountType == accountType } }
            .flatMap { accounts in
                guard let value = accounts.first else {
                    return .error(BlockchainAccountProvidingError.doesNotExist)
                }
                return .just(value)
            }
    }
}
