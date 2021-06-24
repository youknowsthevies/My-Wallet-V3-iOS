// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit

extension AssetSelectorView {

    private var analyticsEventRecorder: AnalyticsEventRecording { resolve() }

    @objc
    func reportOpen() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.AssetSelection.assetSelectorOpen(asset: selectedAsset.cryptoCurrency)
        )
    }

    @objc
    func reportClose() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.AssetSelection.assetSelectorClose(asset: selectedAsset.cryptoCurrency)
        )
    }
}
