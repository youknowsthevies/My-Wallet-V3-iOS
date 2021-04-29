// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@objc class BalanceChartModel: NSObject {
    private var _balance: String?
    @objc var balance: String? {
        get { _balance == nil ? "0" : _balance }
        set { _balance = newValue }
    }
    @objc var fiatBalance: Double = 0
}

@objc class BalanceChartViewModel: BalanceChartModel {
    @objc var watchOnly: BalanceChartModel

    override init() {
        self.watchOnly = BalanceChartModel()
    }
}
