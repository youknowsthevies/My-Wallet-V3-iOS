//
//  TabControllerManager+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 03/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import ToolKit

extension TabControllerManager {
    
    private var analyticsEventRecorder: AnalyticsEventRecording { resolve() }
    
    @objc
    func recordSwapTabItemClick() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Swap.swapTabItemClick
        )
    }
    
    @objc
    func recordSendTabItemClick() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Send.sendTabItemClick
        )
    }
    
    @objc
    func recordActivityTabItemClick() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Transactions.transactionsTabItemClick
        )
    }
    
    @objc
    func recordRequestTabItemClick() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Request.requestTabItemClick
        )
    }
}
