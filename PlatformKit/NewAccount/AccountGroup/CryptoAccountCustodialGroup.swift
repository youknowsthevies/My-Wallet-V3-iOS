//
//  CryptoAccountCustodialGroup.swift
//  PlatformKit
//
//  Created by Paulo on 04/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import Localization

/// An `AccountGroup` containing only Custodial accounts.
public class CryptoAccountCustodialGroup: AccountGroup {
    private typealias LocalizedString = LocalizationConstants.AccountGroup

    private let asset: CryptoCurrency

    private(set) public lazy var id: String = "CryptoAccountCustodialGroup" + asset.code

    public let label: String

    public let accounts: [SingleAccount]

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
        self.label = String(format: LocalizedString.myCustodialWallets, asset.name)
        self.accounts = accounts
    }
}
