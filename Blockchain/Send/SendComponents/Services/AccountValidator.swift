// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import PlatformKit

final class AccountValidator {
    func validate(address: String, as asset: CryptoCurrency) -> Bool {
        switch asset {
        case .ethereum:
            return EthereumAccountAddress(rawValue: address) != nil
        default:
            fatalError("\(#function) does not support \(asset) yet")
        }
    }
}
