// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct EthereumAddress: EthereumAddressProtocols, AssetAddress {

    public let publicKey: String
    public let cryptoCurrency: CryptoCurrency = .ethereum

    public init(stringLiteral value: String) {
        publicKey = EthereumAddressValidator.toChecksumAddress(value)!
    }

    public var isValid: Bool {
        do {
            try EthereumAddressValidator.validate(address: publicKey)
            return true
        } catch {
            return false
        }
    }
}
