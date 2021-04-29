// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@available(*, deprecated, message: "We need to shift to using models returned by Coincore.")
public struct NonCustodialAccountBalance: CryptoAccountBalanceType, Equatable {
    public var available: MoneyValue {
        cryptoValue.moneyValue
    }
    
    public var cryptoCurrency: CryptoCurrency {
        cryptoValue.currencyType
    }
    
    public let cryptoValue: CryptoValue
    
    public init(balance: CryptoValue) {
        self.cryptoValue = balance
    }
}

public extension NonCustodialAccountBalance {
    static func zero(currency: CryptoCurrency) -> NonCustodialAccountBalance {
        .init(balance: .zero(currency: currency))
    }
}
