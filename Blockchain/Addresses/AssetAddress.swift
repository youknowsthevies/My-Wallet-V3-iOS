//
//  AssetAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Blueprint for creating asset addresses.
@objc
protocol AssetAddress {

    var address: String { get }

    @available(*, deprecated, message: "This is deprecated. Use `cryptoCurrency` property instead")
    var assetType: LegacyCryptoCurrency { get }

    var description: String { get }

    init(string: String)
}

extension AssetAddress {
    var cryptoCurrency: CryptoCurrency {
        assetType.value
    }
}

extension AssetAddress {
    var depositAddress: DepositAddress {
        let address: String
        switch cryptoCurrency {
        case .bitcoinCash:
            address = self.address.removing(prefix: "\(Constants.Schemes.bitcoinCash):")
        default:
            address = self.address
        }
        return DepositAddress(type: cryptoCurrency, address: address)
    }
}
