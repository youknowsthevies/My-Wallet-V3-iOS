// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import WalletPayloadKit

final class WalletUpgrading: WalletUpgradingAPI {

    // MARK: Properties

    var isInitialized: Bool {
        wallet.isInitialized()
    }

    var didUpgradeToV3: Bool {
        wallet.didUpgradeToHd()
    }

    var didUpgradeToV4: Bool {
        wallet.didUpgradeToV4
    }

    var requiresV4Upgrade: AnyPublisher<Bool, Error> {
        settings.fetchPublisher(force: true)
            .map(\.features)
            .map { features -> Bool in
                features[.segwit] ?? false
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    // MARK: Private Properties

    private let walletManager: WalletManager
    private let settings: SettingsServiceCombineAPI
    private var wallet: Wallet {
        walletManager.wallet
    }

    // MARK: Init

    init(
        walletManager: WalletManager = .shared,
        settings: SettingsServiceCombineAPI = resolve()
    ) {
        self.settings = settings
        self.walletManager = walletManager
    }
}
