// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import Combine
import WalletPayloadKit

class MockWalletUpgradeService: WalletUpgradeServicing {
    var needsWalletUpgradeRelay = CurrentValueSubject<Bool, Never>(false)

    var needsWalletUpgrade: AnyPublisher<Bool, Never> {
        needsWalletUpgradeRelay
            .eraseToAnyPublisher()
    }

    init() {}

    func upgradeWallet() -> AnyPublisher<String, WalletUpgradeError> {
        .just("")
    }
}
