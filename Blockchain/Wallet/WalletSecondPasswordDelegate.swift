// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore
import PlatformKit

protocol WalletSecondPasswordDelegate: class {
    /// Method invoked when second password is required for JS function to complete.
    func getSecondPassword(success: WalletSuccessCallback, dismiss: WalletDismissCallback?)

    /// Method invoked when a password is required for bip38 private key decryption
    func getPrivateKeyPassword(success: WalletSuccessCallback)
}

extension JSValue: WalletSuccessCallback {
    public func success(string: String) {
        self.call(withArguments: [string])
    }
}

extension JSValue: WalletDismissCallback {
    public func dismiss() {
        guard !self.isUndefined && !self.isNull else { return }
        self.call(withArguments: nil)
    }
}
