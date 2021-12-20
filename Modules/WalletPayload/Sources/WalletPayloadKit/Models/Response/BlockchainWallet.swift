// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

#warning("TODO: temp solution, we should probably move the response models on a seperate module")
enum WalletResponseModels {}

struct BlockchainWallet: Equatable, Codable {
    let guid: String
    let sharedKey: String
    let doubleEncryption: Bool
    let doublePasswordHash: String?
    let metadataHDNode: String?
    let options: Options
    let addresses: [WalletResponseModels.Address]
    let hdWallets: [WalletResponseModels.HDWallet]

    enum CodingKeys: String, CodingKey {
        case guid
        case sharedKey
        case doubleEncryption = "double_encryption"
        case doublePasswordHash = "dpasswordhash"
        case metadataHDNode
        case options
        case addresses = "keys"
        case hdWallets = "hd_wallets"
    }
}
