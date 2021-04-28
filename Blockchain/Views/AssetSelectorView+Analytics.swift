//
//  AssetSelectorView+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import AnalyticsKit
import DIKit
import PlatformKit

extension AssetSelectorView {
    
    private var analyticsEventRecorder: AnalyticsEventRecording { resolve() }
    
    @objc
    func reportOpen() {
        let asset = CryptoCurrency(legacyAssetType: selectedAsset)
        analyticsEventRecorder.record(
            event: AnalyticsEvents.AssetSelection.assetSelectorOpen(asset: asset)
        )
    }
    
    @objc
    func reportClose() {
        let asset = CryptoCurrency(legacyAssetType: selectedAsset)
        analyticsEventRecorder.record(
            event: AnalyticsEvents.AssetSelection.assetSelectorClose(asset: asset)
        )
    }
}
