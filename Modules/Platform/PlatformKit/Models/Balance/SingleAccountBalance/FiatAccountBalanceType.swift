//
//  FiatAccountBalanceType.swift
//  PlatformKit
//
//  Created by Alex McGregor on 9/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "We need to shift to using models returned by Coincore.")
public protocol FiatAccountBalanceType: SingleAccountBalanceType {
    var fiatCurrency: FiatCurrency { get }
    var fiatValue: FiatValue { get }
}
