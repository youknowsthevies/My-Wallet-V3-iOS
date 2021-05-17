// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@available(*, deprecated, message: "We need to shift to using models returned by Coincore.")
public struct CryptoCustodialAccountBalance: CustodialAccountBalanceType, CryptoAccountBalanceType, Equatable {
    public var cryptoCurrency: CryptoCurrency {
        cryptoValue.currencyType
    }
    public let cryptoValue: CryptoValue
    public var available: MoneyValue {
        cryptoValue.moneyValue
    }
    public let withdrawable: MoneyValue
    public let pending: MoneyValue

    public init(available: CryptoValue,
                withdrawable: CryptoValue,
                pending: CryptoValue) {
        self.cryptoValue = available
        self.withdrawable = withdrawable.moneyValue
        self.pending = pending.moneyValue
    }
}

public extension CryptoCustodialAccountBalance {
    static func zero(cryptoCurrency: CryptoCurrency) -> CryptoCustodialAccountBalance {
        .init(
            available: .zero(currency: cryptoCurrency),
            withdrawable: .zero(currency: cryptoCurrency),
            pending: .zero(currency: cryptoCurrency)
        )
    }
}
