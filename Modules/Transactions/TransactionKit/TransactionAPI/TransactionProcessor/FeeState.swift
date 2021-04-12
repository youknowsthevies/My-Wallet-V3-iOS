//
//  FeeState.swift
//  PlatformKit
//
//  Created by Alex McGregor on 10/22/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public enum FeeState: Equatable {
    case feeTooHigh
    case feeUnderMinLimit
    case feeUnderRecommended
    case feeOverRecommended
    case validCustomFee
    case valid(absoluteFee: MoneyValue)
}
