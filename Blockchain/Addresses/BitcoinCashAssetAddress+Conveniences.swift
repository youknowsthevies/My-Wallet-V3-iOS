//
//  BitcoinCashAssetAddress+Rx.swift
//  Blockchain
//
//  Created by Alex McGregor on 6/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit

extension BitcoinCashAssetAddress {
    // TODO: Replace with convenience function in BitcoinKit
    @available(*, deprecated, message: "This should be replaced by a convenience function in BitcoinKit")
    func bitcoinAssetAddress(from wallet: Wallet) -> BitcoinAssetAddress? {
        guard let address = wallet.fromBitcoinCash(publicKey) else {
            return nil
        }
        return BitcoinAssetAddress(publicKey: address)
    }
}
