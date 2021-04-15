//
//  FeeLevelRates.swift
//  TransactionKit
//
//  Created by Alex McGregor on 3/18/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct FeeLevelRates: Equatable {
    public var regularFee: MoneyValue
    public var priorityFee: MoneyValue
}
