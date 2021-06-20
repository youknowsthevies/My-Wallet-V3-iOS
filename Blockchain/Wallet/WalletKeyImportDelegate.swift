// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

protocol WalletKeyImportDelegate: AnyObject {

    func alertUserOfImportedIncorrectPrivateKey()

    func alertUserOfImportedKey()

    func alertUserOfImportedPrivateKeyIntoLegacyAddress()

    func alertUserOfInvalidPrivateKey()

    func askUserToAddWatchOnlyAddress(_ address: AssetAddress, then: @escaping () -> Void)

    func didImportIncorrectPrivateKey()

    func failedToImportPrivateKey(errorDescription: String)

    func failedToImportPrivateKeyForSendingFromWatchOnlyAddress(errorDescription: String)

    func failedToImportPrivateKeyForWatchOnlyAddress(errorDescription: String)

    func importKey(from address: AssetAddress)

    func importedPrivateKeyToLegacyAddress()

    func scanPrivateKeyForWatchOnlyAddress(_ address: AssetAddress)
}
