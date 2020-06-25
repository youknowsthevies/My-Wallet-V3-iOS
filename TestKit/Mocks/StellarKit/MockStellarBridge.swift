//
//  MockXlmWallet.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import StellarKit
import XCTest

class MockStellarBridge: StellarWalletBridgeAPI, MnemonicAccessAPI {
    
    var didCallSave: XCTestExpectation?
    var accounts: [StellarWalletAccount] = []
    
    func save(keyPair: StellarKeyPair, label: String, completion: @escaping MockStellarBridge.KeyPairSaveCompletion) {
        let account = StellarWalletAccount(index: 0, publicKey: keyPair.accountID, label: label, archived: false)
        accounts.append(account)
        completion(nil)
    }

    func stellarWallets() -> [StellarWalletAccount] {
        accounts
    }
    
    // MARK: MnemonicAccessAPI
    
    var mnemonic: Maybe<String> {
        Maybe.empty()
    }
    
    var mnemonicForcePrompt: Maybe<String> {
        Maybe.empty()
    }
    
    var mnemonicPromptingIfNeeded: Maybe<String> {
        Maybe.empty()
    }
    
}
