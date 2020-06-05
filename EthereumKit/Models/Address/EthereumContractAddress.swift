//
//  EthereumAddress.swift
//  EthereumKit
//
//  Created by Jack on 20/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import web3swift

public struct EthereumContractAddress: EthereumAddressProtocols, AssetAddress {

    public let ethereumAddress: EthereumAddress

    public var publicKey: String {
        ethereumAddress.publicKey
    }

    public init(stringLiteral value: String) {
        ethereumAddress = EthereumAddress(stringLiteral: value)
    }
}
