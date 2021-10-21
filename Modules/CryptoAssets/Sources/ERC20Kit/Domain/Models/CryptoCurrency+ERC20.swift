// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension CryptoCurrency {
    var contractAddress: String? {
        assetModel.contractAddress?.publicKey
    }
}
