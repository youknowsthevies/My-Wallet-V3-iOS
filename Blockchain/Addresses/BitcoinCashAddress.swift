//
//  BitcoinCashAddress.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

// TODO: convert class to struct once there are no more objc dependents

@objc
class BitcoinCashAddress: NSObject & AssetAddress {

    // MARK: - Properties

    private(set) var address: String

    let assetType = LegacyCryptoCurrency.bitcoinCash

    override var description: String {
        address
    }

    // MARK: - Initialization

    required init(string: String) {
        self.address = string
    }
}

extension BitcoinCashAddress {
    /// Transforms this BCH address to a `BitcoinAddress`
    ///
    /// - Parameter wallet: a Wallet instance
    /// - Returns: the transformed BTC address
    func toBitcoinAddress(wallet: Wallet) -> BitcoinAddress? {
        guard let btcAddress = wallet.fromBitcoinCash(address) else {
            return nil
        }
        return BitcoinAddress(string: btcAddress)
    }
}
