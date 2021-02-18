//
//  EthereumKeyPairDeriver.swift
//  EthereumKit
//
//  Created by Jack on 13/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import WalletCore

public typealias AnyEthereumKeyPairDeriver = AnyKeyPairDeriver<EthereumKeyPair, EthereumKeyDerivationInput>

public struct EthereumKeyPairDeriver: KeyPairDeriverAPI {
    public func derive(input: EthereumKeyDerivationInput) -> Result<EthereumKeyPair, Error> {
        let ethereumCoinType = CoinType.ethereum
        // Hardcoding BIP39 passphrase as empty string as it is currently not  supported.
        let hdWallet = HDWallet(mnemonic: input.mnemonic, passphrase: "")
        let privateKey = hdWallet.getKeyForCoin(coin: ethereumCoinType)
        let publicKey = hdWallet.getAddressForCoin(coin: ethereumCoinType)
        let ethereumPrivateKey = EthereumPrivateKey(
            mnemonic: input.mnemonic,
            data: privateKey.data
        )
        let keyPair = EthereumKeyPair(
            accountID: publicKey,
            privateKey: ethereumPrivateKey
        )
        return .success(keyPair)
    }
}
