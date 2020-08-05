//
//  Portfolio.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct Portfolio: Codable {
    
    private var accounts: [CryptoCurrency: Account] = [:]
    
    public var balanceFiatValue: FiatValue {
        FiatValue.create(
            amount: balanceChange.balance,
            currency: fiatCurrency
        )
    }
    
    public var changeFiatValue: FiatValue {
        FiatValue.create(
            amount: balanceChange.change,
            currency: fiatCurrency
        )
    }
    
    public subscript(currency: CryptoCurrency) -> Account {
        return accounts[currency]!
    }
    
    public let balanceChange: PortfolioBalanceChange
    public let fiatCurrency: FiatCurrency
    
    public struct Account: Codable {
        let currency: CryptoCurrency
        let balance: String
        
        public init(currency: CryptoCurrency, balance: String) {
            self.currency = currency
            self.balance = balance
        }
    }
    
    public init(ether: String,
                pax: String,
                stellar: String,
                bitcoin: String,
                bitcoinCash: String,
                tether: String,
                balanceChange: PortfolioBalanceChange,
                fiatCurrency: FiatCurrency) {
        accounts[.ethereum] = Account(currency: .ethereum, balance: ether)
        accounts[.pax] = Account(currency: .pax, balance: pax)
        accounts[.stellar] = Account(currency: .stellar, balance: stellar)
        accounts[.bitcoin] = Account(currency: .bitcoin, balance: bitcoin)
        accounts[.bitcoinCash] = Account(currency: .bitcoinCash, balance: bitcoinCash)
        accounts[.tether] = Account(currency: .tether, balance: tether)
        self.balanceChange = balanceChange
        self.fiatCurrency = fiatCurrency
    }
}

public extension Portfolio.Account {
    var cryptoValue: CryptoValue {
        CryptoValue.createFromMinorValue(balance, assetType: currency) ?? CryptoValue.zero(currency: currency)
    }
}
