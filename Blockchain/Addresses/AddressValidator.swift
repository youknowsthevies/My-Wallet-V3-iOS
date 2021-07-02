// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore

@objc
public final class AddressValidator: NSObject {

    // MARK: - Properties

    private let context: JSContext

    // MARK: - Initialization

    @objc init(context: JSContext) {
        self.context = context
    }

    // MARK: - Bitcoin Address Validation

    @objc
    func validate(bitcoinAddress address: String) -> Bool {
        let escapedString = address.escapedForJS()
        guard let result = context.evaluateScriptCheckIsOnMainQueue("Helpers.isBitcoinAddress(\"\(escapedString)\");") else { return false }
        return result.toBool()
    }

    // MARK: - Bitcoin Cash Address Validation

    @objc
    func validate(bitcoinCashAddress address: String) -> Bool {
        let escapedString = address.escapedForJS()
        guard let result = context.evaluateScriptCheckIsOnMainQueue("MyWalletPhone.bch.isValidAddress(\"\(escapedString)\");") else {
            return validate(bitcoinAddress: address)
        }

        let isValidBCHAddress = result.toBool()

        // Fallback on BTC address validation for legacy BCH addresses
        if !isValidBCHAddress {
            return validate(bitcoinAddress: address)
        }

        return isValidBCHAddress
    }

    // MARK: - Ethereum Address Validation

    @objc
    func validate(ethereumAddress address: String) -> Bool {
        let escapedString = address.description.escapedForJS()
        guard let result = context.evaluateScriptCheckIsOnMainQueue("MyWalletPhone.isEthAddress(\"\(escapedString)\");") else { return false }
        return result.toBool()
    }
}
