// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum KeychainPermission: String, Equatable {
    /// The data in the keychain item can be accessed
    /// only while the device is unlocked by the user.
    case whenUnlocked
    /// The data in the keychain item can be accessed
    /// only while the device is unlocked by the user.
    case whenUnlockedThisDeviceOnly
    /// The data in the keychain item cannot be accessed
    /// after a restart until the device has been unlocked once by the user.
    case afterFirstUnlock
    /// The data in the keychain item cannot be accessed
    /// after a restart until the device has been unlocked once by the user.
    case afterFirstUnlockThisDeviceOnly
    /// The data in the keychain can only be accessed
    /// when the device is unlocked. Only available if a passcode is set on the device.
    case whenPasscodeSetThisDeviceOnly

    public var queryValue: CFString {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
