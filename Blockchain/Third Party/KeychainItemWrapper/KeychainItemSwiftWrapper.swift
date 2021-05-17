//
//  KeyChainItemSwiftWrapper.swift
//  Blockchain
//
//  Created by Maciej Burda on 15/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import SettingsKit

struct KeychainItemSwiftWrapper: KeychainItemWrapping {

    func pinFromKeychain() -> String? {
        KeychainItemWrapper.pinFromKeychain()
    }

    func removePinFromKeychain() {
        KeychainItemWrapper.removePinFromKeychain()
    }

    func setPINInKeychain(_ pin: String?) {
        KeychainItemWrapper.setPINInKeychain(pin)
    }

    func guid() -> String? {
        KeychainItemWrapper.guid()
    }

    func removeGuidFromKeychain() {
        KeychainItemWrapper.removeGuidFromKeychain()
    }

    func setGuidInKeychain(_ guid: String?) {
        KeychainItemWrapper.setGuidInKeychain(guid)
    }

    func sharedKey() -> String? {
        KeychainItemWrapper.sharedKey()
    }

    func removeSharedKeyFromKeychain() {
        KeychainItemWrapper.removeSharedKeyFromKeychain()
    }

    func setSharedKeyInKeychain(_ sharedKey: String?) {
        KeychainItemWrapper.setSharedKeyInKeychain(sharedKey)
    }

    func getSingleSwipeAddress(for crypto: CryptoCurrency) -> String? {
        KeychainItemWrapper.getSingleSwipeAddress(for: crypto.legacy)
    }

    func removeAllSwipeAddresses(for crypto: CryptoCurrency) {
        KeychainItemWrapper.removeAllSwipeAddresses(for: crypto.legacy)
    }

    func setSingleSwipeAddress(_ address: String, for crypto: CryptoCurrency) {
        KeychainItemWrapper.setSingleSwipeAddress(address, for: crypto.legacy)
    }

}
