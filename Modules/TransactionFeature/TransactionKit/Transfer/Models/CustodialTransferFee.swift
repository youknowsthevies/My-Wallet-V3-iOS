// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct CustodialTransferFee {
    let fee: [CurrencyType: MoneyValue]
    let minimumAmount: [CurrencyType: MoneyValue]

    public init(fee: [CurrencyType: MoneyValue],
                minimumAmount: [CurrencyType: MoneyValue]) {
        self.fee = fee
        self.minimumAmount = minimumAmount
    }

    subscript(fee currency: CurrencyType) -> MoneyValue {
        self.fee[currency] ?? .zero(currency: currency)
    }
    subscript(minimumAmount currency: CurrencyType) -> MoneyValue {
        self.minimumAmount[currency] ?? .zero(currency: currency)
    }
}
