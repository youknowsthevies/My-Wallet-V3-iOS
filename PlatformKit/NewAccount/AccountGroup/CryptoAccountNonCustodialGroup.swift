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

    public var balance: Single<MoneyValue> {
        if accounts.isEmpty {
            return .just(.zero(asset))
        }
        let asset = self.asset
        return Single.zip( accounts.map(\.balance) )
            .map { values -> MoneyValue in
                try values.reduce(MoneyValue.zero(asset), +)
        }
    }

    public init(asset: CryptoCurrency, accounts: [SingleAccount]) {
        self.asset = asset
        self.label = String(format: LocalizedString.myAccounts, asset.name)
        self.accounts = accounts
    }
}
