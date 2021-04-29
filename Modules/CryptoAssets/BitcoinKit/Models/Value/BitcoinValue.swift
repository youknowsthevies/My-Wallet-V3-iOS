// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

public enum BitcoinValueError: Error {
    case invalidCryptoValue
    case invalidAmount
}

public struct BitcoinValue: CryptoMoney {
    
    public let currency: CurrencyType = .crypto(.bitcoin)
    
    public let currencyType: CryptoCurrency = .bitcoin
    
    public var amount: BigInt {
        crypto.amount
    }
    
    // swiftlint:disable:next force_try
    public static let zero = try! BitcoinValue(crypto: CryptoValue.bitcoinZero)
    
    public var value: CryptoValue {
        crypto.value
    }
    
    private let crypto: CryptoMoney
    
    public init(crypto: CryptoMoney) throws {
        guard crypto.currencyType == .bitcoin else {
            throw BitcoinValueError.invalidCryptoValue
        }
        self.crypto = crypto
    }
    
    public init(satoshis: BigInt) throws {
        self.crypto = CryptoValue.bitcoin(satoshis: satoshis)
    }
}

extension BitcoinValue: Equatable {
    public static func == (lhs: BitcoinValue, rhs: BitcoinValue) -> Bool {
        lhs.amount == rhs.amount
    }
}
