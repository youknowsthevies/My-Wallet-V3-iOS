//
//  BitcoinExternalAssetAddressFactory.swift
//  BitcoinKit
//
//  Created by Alex McGregor on 12/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import TransactionKit

final class BitcoinChainExternalAssetAddressFactory<Token: BitcoinChainToken>: CryptoReceiveAddressFactory {
    
    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) throws -> CryptoReceiveAddress {
        switch Token.coin {
        case .bitcoin:
            return BitcoinChainReceiveAddress<BitcoinToken>(address: address, label: label, onTxCompleted: onTxCompleted)
        case .bitcoinCash:
            let address = address.removing(prefix: "\(AssetConstants.URLSchemes.bitcoinCash):")
            return BitcoinChainReceiveAddress<BitcoinCashToken>(address: address, label: label, onTxCompleted: onTxCompleted)
        }
    }
}
