// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public typealias AvailableActions = Set<AssetAction>

public protocol TradingAccount { }

public protocol BankAccount { }

public protocol NonCustodialAccount { }

public protocol BlockchainAccount {

    /// A unique identifier for this `BlockchainAccount`.
    ///
    /// This may be used to compare if two BlockchainAccount are the same.
    var identifier: AnyHashable { get }

    /// This account label.
    var label: String { get }

    /// The total balance on this account.
    var balance: Single<MoneyValue> { get }

    /// The pending balance of this account.
    var pendingBalance: Single<MoneyValue> { get }

    /// Emits `Set` containing all actions this account can execute.
    var actions: Single<AvailableActions> { get }

    var activity: Single<[ActivityItemEvent]> { get }

    /// Indicates if this account is funded.
    ///
    /// Depending of the account implementation, this may not strictly mean a positive balance.
    /// Some accounts may be set as `isFunded` if they have ever had a positive balance in the past.
    var isFunded: Single<Bool> { get }

    /// The balance of this account exchanged to the given fiat currency.
    func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue>

    /// The balance of this account exchanged to the given fiat currency.
    func fiatBalance(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValue>

    /// The balance of this account exchanged to the given fiat currency.
    func balancePair(fiatCurrency: FiatCurrency) -> Single<MoneyValuePair>

    /// The balance of this account exchanged to the given fiat currency.
    func balancePair(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValuePair>

    /// Checks if this account can execute the given action.
    func can(perform action: AssetAction) -> Single<Bool>

    /// The `ReceiveAddress` for the given account
    var receiveAddress: Single<ReceiveAddress> { get }

    /// The balance, not including uncleared and locked,
    /// that the user is able to utilize in a transaction
    var actionableBalance: Single<MoneyValue> { get }

    /// Some wallets are double encrypted and have a second password.
    var requireSecondPassword: Single<Bool> { get }

    /// The `CurrencyType` of the account
    var currencyType: CurrencyType { get }
}

extension BlockchainAccount {
    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        balancePair(fiatCurrency: fiatCurrency).map(\.quote)
    }

    public func fiatBalance(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValue> {
        balancePair(fiatCurrency: fiatCurrency, at: date).map(\.quote)
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait, Element == [BlockchainAccount] {
    /// Filters an `[BlockchainAccount]` for only `BlockchainAccount`s that can perform the given action.
    /// - parameter failSequence: When `true` re-throws errors raised by any `BlockchainAccount.can(perform:)`. If this is set to `false`, filters out from the emitted element any account whose `BlockchainAccount.can(perform:)` failed.
    public func flatMapFilter(
        action: AssetAction,
        failSequence: Bool,
        onError: ((BlockchainAccount, Error) -> Void)? = nil
    ) -> PrimitiveSequence<SingleTrait, Element> {
        flatMap { accounts -> Single<Element> in
            let elements: [Single<BlockchainAccount?>] = accounts.map { account in
                // Check if account can perform action
                account.can(perform: action)
                    // If account can perform, return itself, else return nil
                    .map { $0 ? account : nil }
                    .catchError { error -> Single<BlockchainAccount?> in
                        onError?(account, error)
                        if failSequence {
                            throw error
                        }
                        return .just(nil)
                    }
            }

            return Single.zip(elements)
                // Filter nil elements (accounts that can't perform action)
                .map { accounts -> Element in
                    accounts.compactMap { $0 }
                }
        }
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait, Element == [SingleAccount] {
    /// Filters an `[SingleAccount]` for only `SingleAccount`s that can perform the given action.
    /// - parameter failSequence: When `true` re-throws errors raised by any `BlockchainAccount.can(perform:)`. If this is set to `false`, filters out from the emitted element any account whose `BlockchainAccount.can(perform:)` failed.
    public func flatMapFilter(
        action: AssetAction,
        failSequence: Bool,
        onError: ((SingleAccount, Error) -> Void)? = nil
    ) -> PrimitiveSequence<SingleTrait, Element> {
        flatMap { accounts -> Single<Element> in
            let elements: [Single<SingleAccount?>] = accounts.map { account in
                // Check if account can perform action
                account.can(perform: action)
                    // If account can perform, return itself, else return nil
                    .map { $0 ? account : nil }
                    .catchError { error -> Single<SingleAccount?> in
                        onError?(account, error)
                        if failSequence {
                            throw error
                        }
                        return .just(nil)
                    }
            }
            return Single.zip(elements)
                // Filter nil elements (accounts that can't perform action)
                .map { accounts -> Element in
                    accounts.compactMap { $0 }
                }
        }
    }

    /// Maps each `[SingleAccount]` object filtering out accounts that match the given `BlockchainAccount` identifier.
    public func mapFilter(excluding identifier: AnyHashable) -> PrimitiveSequence<SingleTrait, Element> {
        map { accounts in
            accounts.filter { $0.identifier != identifier }
        }
    }
}
