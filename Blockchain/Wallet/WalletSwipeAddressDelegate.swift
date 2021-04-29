// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// Protocol definition for the delegate related to swipe to receive addresses
protocol WalletSwipeAddressDelegate: class {

    /// Method invoked when swipe to receive addresses has been retrieved.
    ///
    /// - Parameters:
    ///   - addresses: the addresses
    ///   - assetType: the type of the asset for the retrieved addresses
    func onRetrievedSwipeToReceive(addresses: [String], assetType: CryptoCurrency)
}
