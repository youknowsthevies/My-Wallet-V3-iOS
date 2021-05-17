// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
            .map(\.accounts)
            .map { accounts in
                accounts.filter { account in
                    switch accountType {
                    case .nonCustodial:
                        return account is NonCustodialAccount
                    case .custodial(let type):
                        switch type {
                        case .exchange:
                            return account is ExchangeAccount
                        case .savings:
                            return account is CryptoInterestAccount
                        case .trading:
                            return account is TradingAccount
                        }
                    }
                }
            }
    }

    func accounts(for currency: CurrencyType, accountType: SingleAccountType) -> Single<[BlockchainAccount]> {
        coincore
            .allAccounts
            .map { $0.accounts.filter { $0.currencyType == currency } }
            .map { accounts in
                accounts.filter { account in
                    switch accountType {
                    case .nonCustodial:
                        return account is NonCustodialAccount
                    case .custodial(let type):
                        switch type {
                        case .exchange:
                            return account is ExchangeAccount
                        case .savings:
                            return account is CryptoInterestAccount
                        case .trading:
                            return account is TradingAccount
                        }
                    }
                }
            }
    }

    func account(for currency: CurrencyType, accountType: SingleAccountType) -> Single<BlockchainAccount> {
        coincore
            .allAccounts
            .map { $0.accounts.filter { $0.currencyType == currency } }
            .map { accounts in
                accounts.filter { account in
                    switch accountType {
                    case .nonCustodial:
                        return account is NonCustodialAccount
                    case .custodial(let type):
                        switch type {
                        case .exchange:
                            return account is ExchangeAccount
                        case .savings:
                            return account is CryptoInterestAccount
                        case .trading:
                            return account is TradingAccount
                        }
                    }
                }
            }
            .flatMap { accounts in
                guard let value = accounts.first else {
                    return .error(BlockchainAccountProvidingError.doesNotExist)
                }
                return .just(value)
            }
    }
}
