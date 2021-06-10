// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

/// A `BlockchainAccount` that represents a collection of accounts, opposed to a single account.
public protocol AccountGroup: BlockchainAccount {
    var accounts: [SingleAccount] { get }

    func includes(account: BlockchainAccount) -> Bool
}

extension AccountGroup {
    public var currencyType: CurrencyType {
        guard let type = accounts.first?.currencyType else {
            fatalError("AccountGroup should have at least one account")
        }
        return type
    }

    public func balancePair(fiatCurrency: FiatCurrency) -> Observable<MoneyValuePair> {
        let balances: [Observable<MoneyValuePair>] = accounts
            .map { account in
                account
                    .balancePair(fiatCurrency: fiatCurrency)
                    .catchErrorJustReturn(.zero(baseCurrency: account.currencyType, quoteCurrency: fiatCurrency.currency))
            }
        return Observable.combineLatest(balances)
            .map { [currencyType] pairs -> MoneyValuePair in
                let zero: MoneyValuePair = .zero(baseCurrency: currencyType, quoteCurrency: fiatCurrency.currency)
                return try pairs.reduce(into: zero) { (result, this) in
                    result = try result + this
                }
            }
    }

    public func includes(account: BlockchainAccount) -> Bool {
        accounts.map(\.id).contains(account.id)
    }

    public var actions: Single<AvailableActions> {
        Single.zip(accounts.map(\.actions))
            .map { actions -> AvailableActions in
                actions.reduce(into: AvailableActions()) { $0.formUnion($1) }
            }
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        Single
            .just(accounts.map({ $0.can(perform: action) }))
            .flatMapConcatFirst()
    }
}

public enum AccountGroupError: Error {
    case noBalance
    case noReceiveAddress
}
