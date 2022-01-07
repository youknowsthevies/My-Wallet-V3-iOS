// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct WalletResponse: Equatable, Codable {
    let guid: String
    let sharedKey: String
    let doubleEncryption: Bool
    let doublePasswordHash: String?
    let metadataHDNode: String?
    let options: OptionsResponse
    let addresses: [AddressResponse]
    let hdWallets: [HDWalletResponse]

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

extension NativeWallet {
    convenience init(from blockchainWallet: WalletResponse) {
        self.init(
            guid: blockchainWallet.guid,
            sharedKey: blockchainWallet.sharedKey,
            doubleEncrypted: blockchainWallet.doubleEncryption,
            doublePasswordHash: blockchainWallet.doublePasswordHash,
            metadataHDNode: blockchainWallet.metadataHDNode,
            options: WalletPayloadKit.Options(from: blockchainWallet.options),
            hdWallets: blockchainWallet.hdWallets.map(WalletPayloadKit.HDWallet.init(from:)),
            addresses: blockchainWallet.addresses.map(WalletPayloadKit.Address.init(from:))
        )
    }
}
