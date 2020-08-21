//
//  EthereumValue.swift
//  EthereumKit
//
//  Created by Jack on 19/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit

enum EthereumValueError: Error {
    case invalidCryptoValue
}

public struct EthereumValue: Crypto {
    
    public let currency: CurrencyType = .crypto(.ethereum)
    
    public let currencyType: CryptoCurrency = .ethereum
    
    public var amount: BigInt {
        crypto.amount
    }
    
    public var value: CryptoValue {
        crypto.value
    }
    
    private let crypto: Crypto
    
    public init(crypto: Crypto) throws {
        guard crypto.currencyType == .ethereum else {
            throw EthereumValueError.invalidCryptoValue
        }
        self.crypto = crypto
    }
}
