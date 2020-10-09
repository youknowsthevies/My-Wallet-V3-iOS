//
//  CryptoCurrency+Extensions.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

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
        case .ethereum:
            return .ether
        case .pax:
            return .pax
        case .stellar:
            return .stellar
        case .tether:
            return .tether
        }
    }
    
    /// Returns `true` if an asset's addresses can be reused
    var shouldAddressesBeReused: Bool {
        Set<CryptoCurrency>([.ethereum, .stellar, .pax]).contains(self)
    }

    init(legacyAssetType: LegacyAssetType) {
        switch legacyAssetType {
        case .algorand:
            self = .algorand
        case .bitcoin:
            self = .bitcoin
        case .bitcoinCash:
            self = .bitcoinCash
        case .ether:
            self = .ethereum
        case .stellar:
            self = .stellar
        case .pax:
            self = .pax
        case .tether:
            self = .tether
        }
    }
}
