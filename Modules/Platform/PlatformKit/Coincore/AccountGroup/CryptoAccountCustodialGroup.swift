// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RxSwift

/// An `AccountGroup` containing only Custodial accounts.
public class CryptoAccountCustodialGroup: AccountGroup {
    
    public let label: String

    public let accounts: [SingleAccount]
    
    public var requireSecondPassword: Single<Bool> {
        if accounts.isEmpty {
            return .just(false)
        }
        
        return Single.zip(accounts.map(\.requireSecondPassword))
            .map { values -> Bool in
                !values.contains(false)
            }
    }
    
    public var isFunded: Single<Bool> {
        if accounts.isEmpty {
            return .just(false)
        }
        return Single.zip(accounts.map(\.isFunded))
                    .map { values -> Bool in
                        !values.contains(false)
                    }
    }
    
    public var pendingBalance: Single<MoneyValue> {
        if accounts.isEmpty {
            return .just(.zero(currency: asset))
        }
        let asset = self.asset
        return Single.zip(accounts.map(\.pendingBalance))
            .map { values -> MoneyValue in
                try values.reduce(MoneyValue.zero(currency: asset), +)
            }
    }
    
    public var actionableBalance: Single<MoneyValue> {
        if accounts.isEmpty {
            return .just(.zero(currency: asset))
        }
        let asset = self.asset
        return Single.zip(accounts.map(\.actionableBalance))
            .map { values -> MoneyValue in
                try values.reduce(MoneyValue.zero(currency: asset), +)
            }
    }
    
    public var receiveAddress: Single<ReceiveAddress> {
        account.receiveAddress
    }

    public var balance: Single<MoneyValue> {
        if accounts.isEmpty {
            return .just(.zero(currency: asset))
        }
        let asset = self.asset
        return Single.zip(accounts.map(\.balance))
                    .map { values -> MoneyValue in
                        try values.reduce(MoneyValue.zero(currency: asset), +)
            }
    }
    
    private typealias LocalizedString = LocalizationConstants.AccountGroup

    private let asset: CryptoCurrency
    
    private var account: CryptoAccount {
        guard let account = accounts.first as? CryptoAccount else {
            fatalError("Expected a `CryptoAccount`: \(accounts)")
        }
        return account
    }

    private(set) public lazy var id: String = "CryptoAccountCustodialGroup" + asset.code

    public init(asset: CryptoCurrency, accounts: [SingleAccount]) {
        self.asset = asset
        self.label = String(format: LocalizedString.myCustodialWallets, asset.name)
        self.accounts = accounts
    }
}

extension CryptoAccountCustodialGroup {
    public static func empty(asset: CryptoCurrency) -> CryptoAccountCustodialGroup {
        .init(asset: asset, accounts: [])
    }
}
