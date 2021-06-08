// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension CryptoCurrency {
    var contractAddress: String? {
        guard case .erc20(let model) = self else {
            return nil
        }
        guard case .erc20(let contractAddress, _) = model.kind else {
            return nil
        }
        return contractAddress
    }
}
