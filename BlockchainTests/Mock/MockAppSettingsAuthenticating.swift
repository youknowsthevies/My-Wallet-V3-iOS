// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@testable import Blockchain
import PlatformKit

class MockAppSettings: AppSettingsAuthenticating, AppSettingsAPI, CloudBackupConfiguring {

    var sharedKey: String?
    var guid: String?
    var pin: String?
    var pinKey: String?
    var biometryEnabled: Bool
    var passwordPartHash: String?
    var encryptedPinPassword: String?
    var isPairedWithWallet: Bool = false
    var cloudBackupEnabled: Bool = true

    init(pin: String? = nil,
         pinKey: String? = nil,
         biometryEnabled: Bool = false,
         passwordPartHash: String? = nil,
         encryptedPinPassword: String? = nil,
         sharedKey: String? = nil,
         guid: String? = nil) {
        self.pin = pin
        self.pinKey = pinKey
        self.biometryEnabled = biometryEnabled
        self.passwordPartHash = passwordPartHash
        self.encryptedPinPassword = encryptedPinPassword
        self.sharedKey = sharedKey
        self.guid = guid
    }
}
