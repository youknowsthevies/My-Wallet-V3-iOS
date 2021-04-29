// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import EthereumKit
import PlatformKit

public enum ERC20TokenValueError: Error {
    case invalidCryptoValue
}

public struct ERC20TokenValue<Token: ERC20Token>: CryptoMoney {
    
    public var currency: CurrencyType {
        .crypto(currencyType)
    }
    
    public var currencyType: CryptoCurrency {
        crypto.currencyType
    }
    
    public var amount: BigInt {
        crypto.amount
    }
    
    public var value: CryptoValue {
        crypto.value
    }

    public var moneyValue: MoneyValue {
        value.moneyValue
    }
    
    private let crypto: CryptoMoney
    
    public init(crypto: CryptoMoney) throws {
        guard crypto.currencyType == Token.assetType else {
            throw ERC20TokenValueError.invalidCryptoValue
        }
        self.crypto = crypto
    }
    
    public static func zero<Token: ERC20Token>() -> ERC20TokenValue<Token> {
        let value = CryptoValue.zero(currency: Token.assetType)
        // swiftlint:disable force_try
        return try! ERC20TokenValue<Token>(crypto: value)
    }
}
