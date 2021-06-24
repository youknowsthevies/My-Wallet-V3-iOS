// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension KeychainItemWrapper {
    /// Legacy keys used by Swipe to Receive
    private enum LegacySwipeAddressKey: String, CaseIterable {
        case aave = "aaveSwipeToReceiveAddress"
        case algo = "algoSwipeToReceiveAddress"
        case bch = "bchSwipeAddresses"
        case btc = "btcSwipeAddresses"
        case dot = "dotSwipeToReceiveAddress"
        case eth = "etherAddress"
        case pax = "paxSwipeToReceiveAddress"
        case usdt = "usdtSwipeToReceiveAddress"
        case wdgld = "wdgldSwipeToReceiveAddress"
        case xlm = "xlmSwipeToReceiveAddress"
        case yfi = "yfiSwipeToReceiveAddress"
    }

    private static func removeEntry(for key: String) {
        let keychain = KeychainItemWrapper(identifier: key, accessGroup: nil)
        keychain?.resetKeychainItem()
    }

    /// Removes all swipe to receive address stored on Keychain.
    /// Swipe to Receive is a feature that was removed on release 4.3.0, we need to run this removal process to remove any pre store data from the user keychain.
    static func removeAllSwipeAddresses() {
        LegacySwipeAddressKey.allCases.forEach { key in
            removeEntry(for: key.rawValue)
        }
    }
}
