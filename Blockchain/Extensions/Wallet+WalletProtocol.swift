// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

// MARK: - WalletProtocol

extension Wallet: WalletProtocol {

    /// Returns true if the BTC wallet is funded
    var isBitcoinWalletFunded: Bool {
        getTotalActiveBalance() > 0
    }
}
