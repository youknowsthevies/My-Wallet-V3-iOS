//
//  StellarWalletBridgeMock.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import StellarKit

class StellarWalletBridgeMock: StellarWalletBridgeAPI {

    func save(keyPair: StellarKeyPair, label: String, completion: @escaping StellarWalletBridgeAPI.KeyPairSaveCompletion) {
        let account = StellarWalletAccount(index: 0, publicKey: keyPair.accountID, label: label, archived: false)
        undelyingStellarWallets.append(account)
        completion(nil)
    }

    var undelyingStellarWallets: [StellarWalletAccount] = []
    func stellarWallets() -> [StellarWalletAccount] {
        undelyingStellarWallets
    }
}
