// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

public struct StellarAssetAddress: AssetAddress, Equatable {
    public let publicKey: String
    public let cryptoCurrency: CryptoCurrency = .stellar

    public init(publicKey: String) {
        self.publicKey = publicKey
    }
}
