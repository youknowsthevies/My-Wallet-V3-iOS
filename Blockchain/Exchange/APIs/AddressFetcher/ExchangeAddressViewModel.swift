//
//  ExchangeAddressViewModel.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

/// This is temporary as the `SendBitcoinViewController` will likely be deprecated soon.
@objc
final class ExchangeAddressViewModel: NSObject {
    
    // MARK: - Types

    // MARK: - Properties
    
    @objc let asset: LegacyCryptoCurrency
    @objc var isExchangeLinked = false
    @objc var isTwoFactorEnabled = false
    @objc var address: String?
    
    // MARK: - Setup
    
    @objc
    init(legacyAssetType: LegacyAssetType) {
        self.asset = AssetTypeLegacyHelper.convert(fromLegacy: legacyAssetType)
    }
    
    init(assetType: CryptoCurrency) {
        self.asset = LegacyCryptoCurrency(assetType)
    }
    
    @objc var legacyAssetType: LegacyAssetType {
        asset.legacy
    }
}
