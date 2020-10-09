//
//  Wallet+LegacyBitcoinCashWalletProtocol.swift
//  Blockchain
//
//  Created by Paulo on 13/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol LegacyBitcoinCashWalletProtocol: class {
    var hasBitcoinCashAccount: Bool { get }

    func bitcoinCashDefaultWalletIndex() -> Int?

    func bitcoinCashWallets() -> [[String: Any]]?

    func bitcoinCashDefaultWallet() -> [String: Any]?

    func getBitcoinCashReceiveAddress(forXPub xpub: String) -> String?
}

extension Wallet: LegacyBitcoinCashWalletProtocol {

    func getBitcoinCashReceiveAddress(forXPub xpub: String) -> String? {
        guard isInitialized() else {
            return nil
        }
        let function: String = "MyWalletPhone.bch.getReceivingAddressForAccountXPub(\"\(xpub)\")"
        return context.evaluateScript(function)?.toString()
    }

    var hasBitcoinCashAccount: Bool {
        guard isInitialized() else {
            return false
        }
        return context.evaluateScript("MyWalletPhone.bch.hasAccount()")?.toBool() ?? false
    }

    func bitcoinCashDefaultWallet() -> [String: Any]? {
        guard isInitialized() else {
            return nil
        }
        guard hasBitcoinCashAccount else {
            return nil
        }
        guard let result = context.evaluateScript("MyWalletPhone.bch.getDefaultBCHAccount()")?.toString() else {
            return nil
        }
        guard let data = result.data(using: .utf8),
            let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return nil
        }
        return dictionary
    }

    public func bitcoinCashDefaultWalletIndex() -> Int? {
        guard isInitialized() else {
            return nil
        }
        guard hasBitcoinCashAccount else {
            return nil
        }
        return context.evaluateScript("MyWalletPhone.bch.getDefaultAccountIndex()")?.toNumber()?.intValue
    }

    public func bitcoinCashWallets() -> [[String: Any]]? {
        guard isInitialized() else {
            return nil
        }
        guard hasBitcoinCashAccount else {
            return nil
        }
        guard let result = context.evaluateScript("MyWalletPhone.bch.getAllAccounts()")?.toString() else {
            return nil
        }
        guard let data = result.data(using: .utf8),
            let dictionary = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                return nil
        }
        return dictionary
    }
}
