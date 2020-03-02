//
//  AssetAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Blueprint for creating asset addresses.
@objc
public protocol AssetAddress {

    var address: String { get }

    var assetType: AssetType { get }

    var description: String { get }

    init(string: String)
}

extension AssetAddress {
    var depositAddress: DepositAddress {
        let address: String
        switch assetType {
        case .bitcoinCash:
            address = self.address.removing(prefix: "\(Constants.Schemes.bitcoinCash):")
        default:
            address = self.address
        }
        return DepositAddress(type: assetType.cryptoCurrency, address: address)
    }
}
