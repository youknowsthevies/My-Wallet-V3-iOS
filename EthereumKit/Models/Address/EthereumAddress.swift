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

    public let publicKey: String

    public init(stringLiteral value: String) {
        publicKey = Address.toChecksumAddress(value)!
    }

    public var isValid: Bool {
        web3swiftAddress.isValid
    }

    var web3swiftAddress: web3swift.Address {
        web3swift.Address(publicKey)
    }
}
