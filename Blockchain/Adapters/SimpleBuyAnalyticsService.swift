//
//  SimpleBuyAnalyticsService.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellUIKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

class SimpleBuyAnalyticsService: SimpleBuyAnalayticsServicing {
    
    private let disposeBag = DisposeBag()
    
    func bind(_ relay: PublishRelay<Void>) {
        let analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
        relay
            .map { _ in AnalyticsEvents.SimpleBuy.sbCustodyWalletCardClicked }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
    }
    
    func recordCustodyWalletCardShownEvent() {
        let analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
        analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbCustodyWalletCardShown)
    }
    
    func recordTradingWalletClicked(for currency: CryptoCurrency) {
        let analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
        analyticsRecorder.record(event: AnalyticsEvents.SimpleBuy.sbTradingWalletClicked(asset: currency))
    }
}
