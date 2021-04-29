// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

protocol AssetAddressSubscribing {
    
    /// Subscribes to payments to an asset address
    func subscribe(to address: String, asset: CryptoCurrency, addressType: AssetAddressType)
}
