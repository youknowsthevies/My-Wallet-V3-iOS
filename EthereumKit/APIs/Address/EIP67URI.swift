//
//  EIP67URI.swift
//  EthereumKit
//
//  Created by Jack on 07/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

// TODO: Adopt EIP-681 https://eips.ethereum.org/EIPS/eip-681
public protocol EIP67URI: CryptoAssetQRMetadata {
    init?(address: String, amount: String?, gas: String?)
    init?(url: URL)
    init?(rawValue: String)
}
