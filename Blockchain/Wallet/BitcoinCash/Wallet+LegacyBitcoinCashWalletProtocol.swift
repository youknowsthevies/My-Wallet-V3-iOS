// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol LegacyBitcoinCashWalletProtocol: AnyObject {

    var hasBitcoinCashAccount: Bool { get }

    func updateAccountLabel(
        _ cryptoCurrency: NonCustodialCoinCode,
        index: Int,
        label: String
    ) -> Completable

    func bitcoinCashDefaultWalletIndex() -> Int?

    func bitcoinCashWallets() -> [[String: Any]]?

    func bitcoinCashDefaultWallet() -> [String: Any]?

    func getBitcoinCashReceiveAddress(forXPub xpub: String) -> Result<String, BitcoinReceiveAddressError>

    func validateBitcoinCash(address: String) -> Bool
}

extension Wallet: LegacyBitcoinCashWalletProtocol {

    func validateBitcoinCash(address: String) -> Bool {
        let escapedString = address.escapedForJS()
        guard let result = context.evaluateScriptCheckIsOnMainQueue("MyWalletPhone.bch.isValidAddress(\"\(escapedString)\");") else {
            return false
        }

        return result.toBool()
    }

    func getBitcoinCashReceiveAddress(forXPub xpub: String) -> Result<String, BitcoinReceiveAddressError> {
        guard isInitialized() else {
            return .failure(.uninitialized)
        }
        let function: String = "MyWalletPhone.bch.getReceivingAddressForAccountXPub(\"\(xpub)\")"
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
        guard let result = context.evaluateScriptCheckIsOnMainQueue("MyWalletPhone.bch.getDefaultBCHAccount()")?.toString() else {
            return nil
        }
        guard let data = result.data(using: .utf8),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
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
        return context.evaluateScriptCheckIsOnMainQueue("MyWalletPhone.bch.getDefaultAccountIndex()")?.toNumber()?.intValue
    }

    public func bitcoinCashWallets() -> [[String: Any]]? {
        guard isInitialized() else {
            return nil
        }
        guard hasBitcoinCashAccount else {
            return nil
        }
        guard let result = context.evaluateScriptCheckIsOnMainQueue("MyWalletPhone.bch.getAllAccounts()")?.toString() else {
            return nil
        }
        guard let data = result.data(using: .utf8),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else {
            return nil
        }
        return dictionary
    }
}
