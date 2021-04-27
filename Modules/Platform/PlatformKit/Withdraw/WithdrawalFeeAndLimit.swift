//
//  WithdrawalFeeAndLimit.swift
//  BuySellKit
//
//  Created by Alex McGregor on 4/21/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct WithdrawalFeeAndLimit {
    public let minLimit: FiatValue
    public let fee: FiatValue
}
