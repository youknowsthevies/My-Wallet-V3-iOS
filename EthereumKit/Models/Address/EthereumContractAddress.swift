//
//  EthereumAddress.swift
//  EthereumKit
//
//  Created by Jack on 20/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import web3swift

public struct EthereumContractAddress: EthereumAddressProtocols {

    public var ethereumAddress: EthereumAddress {
        return EthereumAddress(rawValue: rawValue)!
    }

    public let rawValue: String

    public init(stringLiteral value: String) {
        self.rawValue = Address.toChecksumAddress(value)!
    }

    public init?(rawValue value: String) {
        guard let eip55Address = Address.toChecksumAddress(value) else {
            return nil
        }
        self.rawValue = eip55Address
    }
}
