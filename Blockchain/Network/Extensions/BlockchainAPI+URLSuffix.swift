//
//  BlockchainAPI+URLSuffix.swift
//  Blockchain
//
//  Created by Maurice A. on 4/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import NetworkKit
import PlatformKit

extension BlockchainAPI {

    /// Returns the URL for the specified address's asset information (number of transactions,
    /// total sent/received, etc.)
    ///
    /// - Parameter assetAddress: the `AssetAddress`
    /// - Returns: the URL for the `AssetAddress`
    func assetInfoURL(for assetAddress: AssetAddress) -> String? {
        switch assetAddress.cryptoCurrency {
        case .bitcoin:
            return "\(walletUrl)/address/\(assetAddress.address)?format=json"
        case .bitcoinCash:
            return "\(walletUrl)/bch/multiaddr?active=\(assetAddress.address)"
        default:
            return nil
        }
    }

    // TODO: Activity: Can be removed with old activity.
    @available(swift, obsoleted: 1.0, message: "Use transactionDetailURL(for:cryptoCurrency:) instead")
    @objc func transactionDetailURL(for transactionHash: String, assetType: LegacyCryptoCurrency) -> String {
        transactionDetailURL(for: transactionHash, cryptoCurrency: assetType.value)
    }

    /// Returns the URL for the specified address's transaction detail.
    ///
    /// - Parameter transactionHash: the hash of the transaction
    /// - Parameter cryptoCurrency: the `CryptoCurrency`
    /// - Returns: the URL for the transaction detail
    func transactionDetailURL(for transactionHash: String, cryptoCurrency: CryptoCurrency) -> String {
        switch cryptoCurrency {
        case .bitcoin:
            return "\(bitcoinExplorerUrl)/tx/\(transactionHash)"
        case .ethereum:
            return "\(etherExplorerUrl)/tx/\(transactionHash)"
        case .bitcoinCash:
            return "\(bitcoinCashExplorerUrl)/tx/\(transactionHash)"
        case .stellar:
            return "\(stellarchainUrl)/tx/\(transactionHash)"
        case .pax:
            return "\(etherExplorerUrl)/tx/\(transactionHash)"
        }
    }
}
