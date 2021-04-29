// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit

extension SendBitcoinViewController {
    
    private var analyticsEventRecorder: AnalyticsEventRecording { resolve() }
    
    private var asset: CryptoCurrency {
        CryptoCurrency(legacyAssetType: assetType)
    }
    
    @objc
    func reportExchangeButtonClick() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Send.sendFormExchangeButtonClick(asset: asset)
        )
    }
    
    @objc
    func reportFormUseBalanceClick() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Send.sendFormUseBalanceClick(asset: asset)
        )
    }
    
    @objc
    func reportSendFormConfirmClick() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Send.sendFormConfirmClick(asset: asset)
        )
    }

    @objc
    func reportSendFormConfirmSuccess() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Send.sendFormConfirmSuccess(asset: asset)
        )
    }
    
    @objc
    func reportSendFormConfirmFailure() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Send.sendFormConfirmFailure(asset: asset)
        )
    }
    
    @objc
    func reportSendSummaryConfirmClick() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Send.sendSummaryConfirmClick(asset: asset)
        )
    }
    
    @objc
    func reportSendSummaryConfirmSuccess() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Send.sendSummaryConfirmSuccess(asset: asset)
        )
    }
    
    @objc
    func reportSendSummaryConfirmFailure() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Send.sendSummaryConfirmFailure(asset: asset)
        )
    }

    static func make(cryptoCurrency: CryptoCurrency) -> SendBitcoinViewController {
        precondition(cryptoCurrency == .bitcoin || cryptoCurrency == .bitcoinCash,
                     "This screen only supports Bitcoin and Bitcoin Cash")
        let send = SendBitcoinViewController(nibName: "SendBitcoinViewController", bundle: Bundle.main)
        send.assetType = cryptoCurrency.legacy
        return send
    }
}
