// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore
import PlatformKit
import WalletPayloadKit

protocol WalletSecondPasswordDelegate: AnyObject {
    /// Method invoked when second password is required for JS function to complete.
    func getSecondPassword(success: WalletSuccessCallback, dismiss: WalletDismissCallback?)

    /// Method invoked when a password is required for bip38 private key decryption
    func getPrivateKeyPassword(success: WalletSuccessCallback)
}

extension JSValue: WalletSuccessCallback {
    public func success(string: String) {
        call(withArguments: [string])
    }
}

extension JSValue: WalletDismissCallback {
    public func dismiss() {
        guard !isUndefined, !isNull else { return }
        call(withArguments: nil)
    }
}
