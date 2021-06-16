// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import ToolKit

extension CryptoCurrency {

    /// The legacy representation of `CryptoCurrency`
    var legacy: LegacyAssetType {
        switch self {
        case .algorand:
            return .algorand
        case .bitcoin:
            return .bitcoin
        case .bitcoinCash:
            return .bitcoinCash
        case .erc20(.aave):
            return .aave
        case .erc20(.pax):
            return .pax
        case .erc20(.tether):
            return .tether
        case .erc20(.wdgld):
            return .WDGLD
        case .erc20(.yearnFinance):
            return .yearnFinance
        case .erc20:
            impossible()
        case .ethereum:
            return .ether
        case .polkadot:
            return .polkadot
        case .stellar:
            return .stellar
        }
    }

    init(legacyAssetType: LegacyAssetType) {
        switch legacyAssetType {
        case .aave:
            self = .erc20(.aave)
        case .algorand:
            self = .algorand
        case .bitcoin:
            self = .bitcoin
        case .bitcoinCash:
            self = .bitcoinCash
        case .ether:
            self = .ethereum
        case .pax:
            self = .erc20(.pax)
        case .polkadot:
            self = .polkadot
        case .stellar:
            self = .stellar
        case .tether:
            self = .erc20(.tether)
        case .WDGLD:
            self = .erc20(.wdgld)
        case .yearnFinance:
            self = .erc20(.yearnFinance)
        }
    }
}
