// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// The derived Wallet from the response model, `BlockchainWallet`
final class Wallet {
    var guid: String
    var sharedKey: String
    var doubleEncrypted: Bool
    var doublePasswordHash: String?
    var metadataHDNode: String

    init(from blockchainWallet: BlockchainWallet) {
        guid = blockchainWallet.guid
        sharedKey = blockchainWallet.sharedKey
        doubleEncrypted = blockchainWallet.doubleEncryption
        doublePasswordHash = blockchainWallet.doublePasswordHash

        metadataHDNode = blockchainWallet.metadataHDNode
    }
}
