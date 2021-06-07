// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct Portfolio: Codable {

    private var accounts: [CryptoCurrency: Account] = [:]

    public var balanceFiatValue: FiatValue {
        FiatValue.create(
            major: balanceChange.balance,
            currency: fiatCurrency
        )
    }

    public var changeFiatValue: FiatValue {
        FiatValue.create(
            major: balanceChange.change,
            currency: fiatCurrency
        )
    }

    public subscript(currency: CryptoCurrency) -> Account {
        accounts[currency]!
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
        accounts[.erc20(.pax)] = Account(currency: .erc20(.pax), balance: pax)
        accounts[.stellar] = Account(currency: .stellar, balance: stellar)
        accounts[.bitcoin] = Account(currency: .bitcoin, balance: bitcoin)
        accounts[.bitcoinCash] = Account(currency: .bitcoinCash, balance: bitcoinCash)
        accounts[.erc20(.tether)] = Account(currency: .erc20(.tether), balance: tether)
        self.balanceChange = balanceChange
        self.fiatCurrency = fiatCurrency
    }
}

public extension Portfolio.Account {
    var cryptoValue: CryptoValue {
        CryptoValue.create(minor: balance, currency: currency) ?? CryptoValue.zero(currency: currency)
    }
}
