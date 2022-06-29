// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletCore

public enum BitcoinScriptType: String {
    /// Pay-to-Public-Key-Hash
    case P2PKH
    /// Pay-to-Script-Hash
    case P2SH
    /// Pay-to-Witness-Public-Key-Hash
    case P2WPKH
    /// Pay-to-Witness-Script-Hash
    case P2WSH

    public init?(scriptData: Data) {
        let script = BitcoinScript(data: scriptData)
        if script.isPayToWitnessPublicKeyHash {
            self = .P2WPKH
        } else if script.isPayToWitnessScriptHash {
            self = .P2WSH
        } else if script.isPayToScriptHash {
            self = .P2SH
        } else if script.matchPayToPubkeyHash() != nil {
            self = .P2PKH
        } else {
            return nil
        }
    }

    public init?(address: String, coin: BitcoinChainCoin) {
        let lockScript = WalletCore.BitcoinScript.lockScriptForAddress(
            address: address,
            coin: coin.walletCoreCoinType
        )
        self.init(scriptData: lockScript.data)
    }
}
