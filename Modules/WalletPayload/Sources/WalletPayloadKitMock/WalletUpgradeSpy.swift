// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadKit

import Combine
import ToolKit
import WalletPayloadDataKit

final class WalletUpgraderSpy: WalletUpgraderAPI {

    let realUpgrader: WalletUpgraderAPI

    init(realUpgrader: WalletUpgraderAPI) {
        self.realUpgrader = realUpgrader
    }

    var upgradedNeededCalled: Bool = false
    func upgradedNeeded(wrapper: Wrapper) -> Bool {
        upgradedNeededCalled = true
        return realUpgrader.upgradedNeeded(wrapper: wrapper)
    }

    var performUpgradeCalled: Bool = false
    func performUpgrade(wrapper: Wrapper) -> AnyPublisher<Wrapper, WalletUpgradeError> {
        performUpgradeCalled = true
        return realUpgrader.performUpgrade(wrapper: wrapper)
    }
}
