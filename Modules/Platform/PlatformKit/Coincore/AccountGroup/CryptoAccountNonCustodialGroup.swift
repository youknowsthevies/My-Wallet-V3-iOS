//
//  CryptoAccountNonCustodialGroup.swift
//  PlatformKit
//
//  Created by Paulo on 03/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import RxSwift

/// An `AccountGroup` containing only Non Custodial accounts.
public class CryptoAccountNonCustodialGroup: AccountGroup {
    private typealias LocalizedString = LocalizationConstants.AccountGroup
    
    private let asset: CryptoCurrency
    
    private(set) public lazy var id: String = "CryptoAccountNonCustodialGroup" + asset.code
    
    public let label: String
    
    public let accounts: [SingleAccount]
    
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
        .error(AccountGroupError.noReceiveAddress)
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

    public init(asset: CryptoCurrency, accounts: [SingleAccount]) {
        self.asset = asset
        self.label = String(format: LocalizedString.myWallets, asset.name)
        self.accounts = accounts
    }
}
