// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct EthereumContractAddress: EthereumAddressProtocols, AssetAddress {
    public let cryptoCurrency: CryptoCurrency = .ethereum

    public let ethereumAddress: EthereumAddress

    public var publicKey: String {
        ethereumAddress.publicKey
    }

    public init(stringLiteral value: String) {
        ethereumAddress = EthereumAddress(stringLiteral: value)
    }
}
