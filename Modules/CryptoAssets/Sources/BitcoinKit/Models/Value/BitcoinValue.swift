// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

public enum BitcoinValueError: Error {
    case invalidCryptoValue
}

public struct BitcoinValue: CryptoMoney {

    public let currencyType: CurrencyType = .crypto(.coin(.bitcoin))

    public let currency: CryptoCurrency = .coin(.bitcoin)

    public var amount: BigInt {
        crypto.amount
    }

    public static let zero = BitcoinValue(minor: 0)

    private let crypto: CryptoMoney

    public init(crypto: CryptoMoney) throws {
        guard crypto.currencyType == .coin(.bitcoin) else {
            throw BitcoinValueError.invalidCryptoValue
        }
        self.crypto = crypto
    }

    public init(minor value: Decimal) {
        crypto = CryptoValue.create(minor: value, currency: .coin(.bitcoin))
    }

    public init(minor value: Int) {
        crypto = CryptoValue.create(minor: value, currency: .coin(.bitcoin))
    }

    public init(minor value: BigInt) {
        crypto = CryptoValue.create(minor: value, currency: .coin(.bitcoin))
    }
}

extension BitcoinValue: Equatable {
    public static func == (lhs: BitcoinValue, rhs: BitcoinValue) -> Bool {
        lhs.amount == rhs.amount
    }
}
