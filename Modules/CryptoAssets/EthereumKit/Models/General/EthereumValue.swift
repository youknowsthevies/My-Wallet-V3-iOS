// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

enum EthereumValueError: Error {
    case invalidCryptoValue
}

public struct EthereumValue: CryptoMoney {
    
    public let currency: CurrencyType = .crypto(.ethereum)
    
    public let currencyType: CryptoCurrency = .ethereum
    
    public var amount: BigInt {
        crypto.amount
    }
    
    public var value: CryptoValue {
        crypto.value
    }
    
    private let crypto: CryptoMoney
    
    public init(crypto: CryptoMoney) throws {
        guard crypto.currencyType == .ethereum else {
            throw EthereumValueError.invalidCryptoValue
        }
        self.crypto = crypto
    }
}
