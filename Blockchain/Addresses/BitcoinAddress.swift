//
//  BitcoinAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

// TODO: convert class to struct once there are no more objc dependents

@objc
class BitcoinAddress: NSObject & AssetAddress {

    // MARK: - Properties

    private(set) var address: String

    let assetType = LegacyCryptoCurrency.bitcoin

    override var description: String {
        return address
    }

    // MARK: - Initialization

    required init(string: String) {
        self.address = string
    }
}

extension BitcoinAddress {
    /// Transforms this BTC address to a `BitcoinCashAddress`
    ///
    /// - Parameter wallet: a Wallet instance
    /// - Returns: the transformed BTC address
    @objc func toBitcoinCashAddress(wallet: Wallet) -> BitcoinCashAddress? {
        guard let bchAddress = wallet.toBitcoinCash(address, includePrefix: false) else {
            return nil
        }
        return BitcoinCashAddress(string: bchAddress)
    }
}
