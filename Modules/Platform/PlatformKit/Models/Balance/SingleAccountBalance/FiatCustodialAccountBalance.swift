// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@available(*, deprecated, message: "We need to shift to using models returned by Coincore.")
public struct FiatCustodialAccountBalance: CustodialAccountBalanceType, FiatAccountBalanceType, Equatable {
    public var fiatCurrency: FiatCurrency {
        fiatValue.currencyType
    }
    public var available: MoneyValue {
        .init(fiatValue: fiatValue)
    }
    public let fiatValue: FiatValue
    public let withdrawable: MoneyValue
    public let pending: MoneyValue

    public init(available: FiatValue,
                withdrawable: FiatValue,
                pending: FiatValue) {
        self.fiatValue = available
        self.withdrawable = withdrawable.moneyValue
        self.pending = pending.moneyValue
    }
}

public extension FiatCustodialAccountBalance {
    static func zero(fiatCurrency: FiatCurrency) -> FiatCustodialAccountBalance {
        .init(
            available: .zero(currency: fiatCurrency),
            withdrawable: .zero(currency: fiatCurrency),
            pending: .zero(currency: fiatCurrency)
        )
    }
}
