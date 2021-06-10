// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import SettingsKit

class MockKeychainItemWrapping: KeychainItemWrapping {
    var pinFromKeychainValue: String?
    func pinFromKeychain() -> String? {
        pinFromKeychainValue
    }

    var removePinFromKeychainCalled: Bool = false
    func removePinFromKeychain() {
        removePinFromKeychainCalled = true
    }

    var setPINInKeychainCalled: (pin: String?, called: Bool) = (nil, false)
    func setPINInKeychain(_ pin: String?) {
        setPINInKeychainCalled = (pin, true)
    }

    var guidValue: String?
    func guid() -> String? {
        guidValue
    }

    var removeGuidFromKeychainCalled: Bool = false
    func removeGuidFromKeychain() {
        removeGuidFromKeychainCalled = true
    }

    var setGuidInKeychainCalled: (guid: String?, called: Bool) = (nil, false)
    func setGuidInKeychain(_ guid: String?) {
        setGuidInKeychainCalled = (guid, true)
    }

    var sharedKeyValue: String?
    func sharedKey() -> String? {
        sharedKeyValue
    }

    var removeSharedKeyFromKeychainCalled: Bool = false
    func removeSharedKeyFromKeychain() {
        removeSharedKeyFromKeychainCalled = true
    }

    var setSharedKeyInKeychainCalled: (sharedKey: String?, called: Bool) = (nil, false)
    func setSharedKeyInKeychain(_ sharedKey: String?) {
        setSharedKeyInKeychainCalled = (sharedKey, true)
    }

    var getSingleSwipeAddressCalled: (currency: CryptoCurrency?, called: Bool) = (nil, false)
    var getSingleSwipeAddressValue: String?
    func getSingleSwipeAddress(for: CryptoCurrency) -> String? {
        getSingleSwipeAddressCalled = (`for`, true)
        return getSingleSwipeAddressValue
    }

    var removeAllSwipeAddressesCalled: (currency: CryptoCurrency?, called: Bool) = (nil, false)
    func removeAllSwipeAddresses(for: CryptoCurrency) {
        removeAllSwipeAddressesCalled = (`for`, true)
    }

    var setSingleSwipeAddressCalled: (address: String?, currency: CryptoCurrency?, called: Bool) = (nil, nil, false)
    func setSingleSwipeAddress(_ address: String, for: CryptoCurrency) {
        setSingleSwipeAddressCalled = (address, `for`, true)
    }
}
