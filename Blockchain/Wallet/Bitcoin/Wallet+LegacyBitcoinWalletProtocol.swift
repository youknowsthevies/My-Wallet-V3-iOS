//
//  Wallet+LegacyBitcoinWalletProtocol.swift
//  Blockchain
//
//  Created by Jack on 12/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import JavaScriptCore

protocol LegacyBitcoinWalletProtocol: class {
    
    func bitcoinDefaultWalletIndex(with secondPassword: String?, success: @escaping (Int) -> Void, error: @escaping (String) -> Void)
    
    func bitcoinWalletIndex(receiveAddress: String, success: @escaping (Int32) -> Void, error: @escaping (String) -> Void)
    
    func bitcoinWallets(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    
    func hdWallet(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)

    func getBitcoinMemo(for transaction: String, success: @escaping (String?) -> Void, error: @escaping (String) -> Void)

    func saveBitcoinMemo(for transaction: String, memo: String?)

    func getBitcoinReceiveAddress(forXPub xpub: String) -> String?
}

extension Wallet: LegacyBitcoinWalletProtocol {

    func getBitcoinReceiveAddress(forXPub xpub: String) -> String? {
        guard isInitialized() else {
            return nil
        }
        let function: String = "MyWalletPhone.getReceivingAddressForAccountXPub(\"\(xpub)\")"
        return context.evaluateScript(function)?.toString()
    }

    func saveBitcoinMemo(for transaction: String, memo: String?) {
        guard isInitialized() else {
            return
        }
        let function: String
        if let memo = memo, !memo.isEmpty {
            function = "MyWallet.wallet.setNote(\"\(transaction.escapedForJS())\", \"\(memo.escapedForJS())\")"
        } else {
            function = "MyWallet.wallet.deleteNote(\"\(transaction.escapedForJS())\")"
        }
        context.evaluateScript(function)
    }

    func getBitcoinMemo(for transaction: String, success: @escaping (String?) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        let function: String = "MyWalletPhone.getBitcoinNote(\"\(transaction.escapedForJS())\")"
        guard
            let result: String = context.evaluateScript(function)?.toString(),
            !result.isEmpty,
            result != "null",
            result != "undefined"
            else {
                success(nil)
                return
        }
        success(result)
    }

    func bitcoinDefaultWalletIndex(with secondPassword: String?, success: @escaping (Int) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        bitcoin.interopDispatcher.getDefaultWalletIndex.addObserver { result in
            switch result {
            case .success(let defaultWalletIndex):
                success(defaultWalletIndex)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getDefaultBitcoinWalletIndexAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
    }
    
    func bitcoinWalletIndex(receiveAddress: String, success: @escaping (Int32) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        bitcoin.interopDispatcher.getWalletIndex.addObserver { result in
            switch result {
            case .success(let defaultWalletIndex):
                success(defaultWalletIndex)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getBitcoinWalletIndexAsync"
        let script: String
        let address = receiveAddress.escapedForJS()
        
        script = "\(function)(\"\(address)\")"
        context.evaluateScript(script)
    }
    
    func bitcoinWallets(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        bitcoin.interopDispatcher.getAccounts.addObserver { result in
            switch result {
            case .success(let accounts):
                success(accounts)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getBitcoinWalletsAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
    }
    
    func hdWallet(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        bitcoin.interopDispatcher.getHDWallet.addObserver { result in
            switch result {
            case .success(let wallet):
                success(wallet)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.getHDWalletAsync"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScript(script)
    }
}
