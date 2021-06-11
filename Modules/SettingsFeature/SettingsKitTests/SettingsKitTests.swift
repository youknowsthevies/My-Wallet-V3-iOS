@testable import SettingsKit

import PlatformKit
import XCTest

class SettingsKitTests: XCTestCase {

}

class MockBlockchainSettingsApp: BlockchainSettings.App {
    override init(enabledCurrenciesService: EnabledCurrenciesServiceAPI = MockEnabledCurrenciesService(),
                  keychainItemWrapper: KeychainItemWrapping = MockKeychainItemWrapping(),
                  legacyPasswordProvider: LegacyPasswordProviding = MockLegacyPasswordProvider()) {

    }
}
