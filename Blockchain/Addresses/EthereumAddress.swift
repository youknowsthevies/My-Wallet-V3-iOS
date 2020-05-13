//
//  EthereumAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 5/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "This is deprecated. Use `EthereumKit.EthereumAddress` instead")
class EthereumAddress: NSObject & AssetAddress {

    // MARK: - Properties

    let address: String
    let assetType: LegacyCryptoCurrency = .ethereum

    override var description: String {
        address
    }

    // MARK: - Initialization

    required init(string: String) {
        address = string
    }
}
