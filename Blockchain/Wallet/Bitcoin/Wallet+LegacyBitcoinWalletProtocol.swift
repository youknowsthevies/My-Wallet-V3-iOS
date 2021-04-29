// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import JavaScriptCore

protocol LegacyBitcoinWalletProtocol: class {
    
    func bitcoinDefaultWalletIndex(with secondPassword: String?, success: @escaping (Int) -> Void, error: @escaping (String) -> Void)
    
    func bitcoinWalletIndex(receiveAddress: String, success: @escaping (Int32) -> Void, error: @escaping (String) -> Void)
    
    func bitcoinWallets(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)

    func getBitcoinMemo(for transaction: String, success: @escaping (String?) -> Void, error: @escaping (String) -> Void)

    func saveBitcoinMemo(for transaction: String, memo: String?)

    func getBitcoinReceiveAddress(forXPub xpub: String, derivation: BitcoinDerivation) -> Result<String, BitcoinReceiveAddressError>
    
    func validateBitcoin(address: String) -> Bool
    
    func getSignedBitcoinPayment(with secondPassword: String?, success: @escaping (String, Int) -> Void, error: @escaping (String) -> Void)
}

enum BitcoinReceiveAddressError: Error {
    case incompleteAddress
    case uninitialized
    case jsReturnedNil
    case jsValueNotString
    case jsValueEmptyString
}

enum BitcoinDerivation {
    case `default`
    case legacy
}

extension Wallet: LegacyBitcoinWalletProtocol {
    
    func getSignedBitcoinPayment(with secondPassword: String?, success: @escaping (String, Int) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        bitcoin.interopDispatcher.getSignedPayment.addObserver { result in
            switch result {
            case .success(let payment):
                success(payment.0, payment.1)
            case .failure(let errorMessage):
                error(errorMessage.localizedDescription)
            }
        }
        let function: String = "MyWalletPhone.signBitcoinPayment"
        let script: String
        if let escapedSecondPassword = secondPassword?.escapedForJS() {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScriptCheckIsOnMainQueue(script)
    }
    
    func validateBitcoin(address: String) -> Bool {
        let escapedString = address.escapedForJS()
        guard let result = context.evaluateScriptCheckIsOnMainQueue("Helpers.isBitcoinAddress(\"\(escapedString)\");") else { return false }
        return result.toBool()
    }

    func getBitcoinReceiveAddress(forXPub xpub: String, derivation: BitcoinDerivation) -> Result<String, BitcoinReceiveAddressError> {
        guard isInitialized() else {
            return .failure(.uninitialized)
        }
        let forceLegacy: String
        switch derivation {
        case .legacy:
            forceLegacy = "true"
        case .default:
            forceLegacy = "false"
        }
        let function: String = "MyWalletPhone.getReceivingAddressForAccountXPub(\"\(xpub)\",\(forceLegacy))"
        guard let jsResult = context.evaluateScriptCheckIsOnMainQueue(function) else {
            return .failure(.jsReturnedNil)
        }
        guard let result: String = jsResult.toString() else {
            return .failure(.jsValueNotString)
        }
        guard !result.isEmpty else {
            return .failure(.jsValueEmptyString)
        }
        return .success(result)
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
        context.evaluateScriptCheckIsOnMainQueue(function)
    }

    func getBitcoinMemo(for transaction: String, success: @escaping (String?) -> Void, error: @escaping (String) -> Void) {
        guard isInitialized() else {
            error("Wallet is not yet initialized.")
            return
        }
        let function: String = "MyWalletPhone.getBitcoinNote(\"\(transaction.escapedForJS())\")"
        guard
            let result: String = context.evaluateScriptCheckIsOnMainQueue(function)?.toString(),
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
        if let escapedSecondPassword = secondPassword?.escapedForJS(wrapInQuotes: true) {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScriptCheckIsOnMainQueue(script)
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
        context.evaluateScriptCheckIsOnMainQueue(script)
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
        if let escapedSecondPassword = secondPassword?.escapedForJS(wrapInQuotes: true) {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScriptCheckIsOnMainQueue(script)
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
        if let escapedSecondPassword = secondPassword?.escapedForJS(wrapInQuotes: true) {
            script = "\(function)(\(escapedSecondPassword))"
        } else {
            script = "\(function)()"
        }
        context.evaluateScriptCheckIsOnMainQueue(script)
    }
}
