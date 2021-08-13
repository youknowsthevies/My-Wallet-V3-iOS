// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import SettingsKit

final class MockBlockchainSettingsApp: BlockchainSettingsAppAPI {

    // MARK: BlockchainSettingsAppAPI

    var biometryEnabled: Bool = false
    var browserIdentities: String?
    var cloudBackupEnabled: Bool = true
    var deviceKey: String?
    var didRequestCameraPermissions: Bool = false
    var didRequestMicrophonePermissions: Bool = false
    var didRequestNotificationPermissions: Bool = false
    var encryptedPinPassword: String?
    var guid: String?
    var isPairedWithWallet: Bool = false
    var isPinSet: Bool = false
    var onSymbolLocalChanged: ((Bool) -> Void)?
    var passwordPartHash: String?
    var pin: String?
    var pinKey: String?
    var sharedKey: String?
    var symbolLocal: Bool = false {
        didSet {
            if oldValue != symbolLocal {
                onSymbolLocalChanged?(symbolLocal)
            }
        }
    }

    func clearPin() {
        clearPinCalled = true
    }

    func reset() {
        resetCalled = true
    }

    // MARK: Mock Supporting

    var clearPinCalled: Bool = false
    var resetCalled: Bool = false
}
