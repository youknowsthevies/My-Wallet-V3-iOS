// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
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

    var requiresV4Upgrade: Single<Bool> {
        settings.fetch(force: true)
            .map(\.features)
            .map { features -> Bool in
                features[.segwit] ?? false
            }
    }

    // MARK: Private Properties

    private let walletManager: WalletManager
    private let settings: SettingsServiceAPI
    private var wallet: Wallet {
        walletManager.wallet
    }

    // MARK: Init

    init(walletManager: WalletManager = .shared,
         settings: SettingsServiceAPI = resolve()) {
        self.settings = settings
        self.walletManager = walletManager
    }
}
