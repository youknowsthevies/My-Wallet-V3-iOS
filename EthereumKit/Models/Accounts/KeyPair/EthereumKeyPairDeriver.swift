//
//  EthereumKeyPairDeriver.swift
//  EthereumKit
//
//  Created by Jack on 13/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import web3swift

public class EthereumKeyPairDeriver: EthereumKeyPairDeriverAPI {
    static let shared = EthereumKeyPairDeriver()
    
    public func derive(input: EthereumKeyDerivationInput) -> Result<EthereumKeyPair, Error> {
        let mnemonic = input.mnemonic
        let password = input.password
        let mnemonics: Mnemonics
        let keystore: BIP32Keystore
        let privateKey: Data
        let publicKey: Data
        let accountAddress: String

        // swiftlint:disable force_try
        mnemonics = try! Mnemonics(mnemonic)
        keystore = try! BIP32Keystore(
            mnemonics: mnemonics,
            password: password,
            prefixPath: HDNode.defaultPathMetamaskPrefix
        )
        let address = keystore.addresses[0]
        privateKey = try! keystore.UNSAFE_getPrivateKeyData(password: password, account: address)
        publicKey = try! Web3Utils.privateToPublic(privateKey, compressed: true)
        accountAddress = try! Web3Utils.publicToAddressString(publicKey)

        return .success(
            EthereumKeyPair(
                accountID: accountAddress,
                privateKey: EthereumPrivateKey(
                    mnemonic: mnemonic,
                    password: password,
                    data: privateKey
                )
            )
        )
    }
}
