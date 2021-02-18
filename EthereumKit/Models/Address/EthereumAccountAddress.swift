//
//  EthereumAccountAddress.swift
//  EthereumKit
//
//  Created by Jack on 20/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public struct EthereumAccountAddress: EthereumAddressProtocols {

    public var ethereumAddress: EthereumAddress {
        EthereumAddress(stringLiteral: rawValue)
    }

    public let rawValue: String

    public init(string address: String) throws {
        try EthereumAddressValidator.validate(address: address)
        guard let eip55Address = EthereumAddressValidator.toChecksumAddress(address) else {
            throw AddressValidationError.eip55ChecksumFailed
        }
        self.rawValue = eip55Address
    }

    public init(stringLiteral value: String) {
        self.rawValue = EthereumAddressValidator.toChecksumAddress(value)!
    }

    public init?(rawValue value: String) {
        try? self.init(string: value)
    }
}
