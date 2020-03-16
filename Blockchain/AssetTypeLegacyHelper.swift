//
//  AssetTypeLegacyHelper.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Helper to convert between CryptoCurrency <-> LegacyAssetType.
// To be deprecated once LegacyAssetType has been removed.
@objc class AssetTypeLegacyHelper: NSObject {
    
    @objc
    static func convert(fromLegacy type: LegacyAssetType) -> LegacyCryptoCurrency {
        return LegacyCryptoCurrency(CryptoCurrency(legacyAssetType: type))
    }

    @objc
    static func convert(toLegacy type: LegacyCryptoCurrency) -> LegacyAssetType {
        return type.legacy
    }

    @objc
    static func name(for type: LegacyCryptoCurrency) -> String {
        return type.name
    }
    
    @objc
    static func name(from legacy: LegacyAssetType) -> String {
        return name(for: .init(legacy))
    }

    @objc
    static func color(for type: LegacyAssetType) -> UIColor {
        return CryptoCurrency(legacyAssetType: type).brandColor
    }

    @objc
    static func code(for type: LegacyAssetType) -> String {
        return CryptoCurrency(legacyAssetType: type).code
    }
    
    @objc
    static func displayCode(for type: LegacyAssetType) -> String {
        return CryptoCurrency(legacyAssetType: type).displayCode
    }
}
