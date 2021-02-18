//
//  EthereumKeyDerivationInput.swift
//  EthereumKit
//
//  Created by Jack on 08/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

// Derivation Input for a HDWallet given a BIP39 mnemonic
// BIP39 Passphrase is currently not supported.
public struct EthereumKeyDerivationInput: KeyDerivationInput, Equatable {
    public let mnemonic: String
    
    public init(mnemonic: String) {
        self.mnemonic = mnemonic
    }
}
