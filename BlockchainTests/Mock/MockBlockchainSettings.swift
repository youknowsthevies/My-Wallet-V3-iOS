// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@testable import PlatformKit
@testable import SettingsKit

class MockBlockchainSettingsApp: BlockchainSettings.App {
    var mockDidAttemptToRouteForAirdrop: Bool = false
    var mockDidTapOnAirdropDeepLink: Bool = false
    var mockGuid: String?
    var mockSharedKey: String?
    var mockIsPinSet: Bool = false
    var mockIsPairedWithWallet: Bool = false
    var mockEncryptedPinPassword: String?
    var mockPinKey: String?

    override init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        keychainItemWrapper: KeychainItemWrapping,
        legacyPasswordProvider: LegacyPasswordProviding
    ) {
        super.init()
    }

    override var isPairedWithWallet: Bool {
        mockIsPairedWithWallet
    }

    override var encryptedPinPassword: String? {
        get {
            mockEncryptedPinPassword
        }
        set {
            mockEncryptedPinPassword = newValue
        }
    }

    override var pinKey: String? {
        get {
            mockPinKey
        }
        set {
            mockPinKey = newValue
        }
    }

    override var isPinSet: Bool {
        get {
            mockIsPinSet
        }
        set {
            mockIsPinSet = newValue
        }
    }

    override var guid: String? {
        get {
            mockGuid
        }
        set {
            mockGuid = newValue
        }
    }

    override var sharedKey: String? {
        get {
            mockSharedKey
        }
        set {
            mockSharedKey = newValue
        }
    }

    override var didTapOnAirdropDeepLink: Bool {
        get {
            mockDidTapOnAirdropDeepLink
        }
        set {
            mockDidTapOnAirdropDeepLink = newValue
        }
    }

    override var didAttemptToRouteForAirdrop: Bool {
        get {
            mockDidAttemptToRouteForAirdrop
        }
        set {
            mockDidAttemptToRouteForAirdrop = newValue
        }
    }

    var clearPinCalled = false

    override func clearPin() {
        clearPinCalled = true
    }

    var resetCalled = false

    override func reset() {
        resetCalled = true
    }
}
