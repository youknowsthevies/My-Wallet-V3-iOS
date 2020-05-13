//
//  EthereumAddress.swift
//  EthereumKit
//
//  Created by Jack on 20/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import web3swift

public struct EthereumAddress: EthereumAddressProtocols, AssetAddress {
    
    public let rawValue: String

    public var publicKey: String {
        rawValue
    }

    public init(stringLiteral value: String) {
        rawValue = Address.toChecksumAddress(value)!
    }

    public init?(rawValue value: String) {
        guard let eip55Address = Address.toChecksumAddress(value) else {
            return nil
        }
        rawValue = eip55Address
    }

    public var isValid: Bool {
        web3swiftAddress.isValid
    }

    var web3swiftAddress: web3swift.Address {
        web3swift.Address(rawValue)
    }

    public static func ==(lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
