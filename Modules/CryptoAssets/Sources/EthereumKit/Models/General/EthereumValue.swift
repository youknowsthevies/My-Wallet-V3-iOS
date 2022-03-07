// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

enum EthereumValueError: Error {
    case invalidCryptoValue
}

public struct EthereumValue: CryptoMoney {

    public let currencyType: CurrencyType = .crypto(.ethereum)

    public let currency: CryptoCurrency = .ethereum

    public var amount: BigInt {
        crypto.amount
    }

    private let crypto: CryptoMoney

    public init(crypto: CryptoMoney) throws {
        guard crypto.currencyType == .ethereum else {
            throw EthereumValueError.invalidCryptoValue
        }
        self.crypto = crypto
    }
}
