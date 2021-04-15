//
//  CustodialAccountBalanceType.swift
//  PlatformKit
//
//  Created by Alex McGregor on 9/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@available(*, deprecated, message: "We need to shift to using models returned by Coincore.")
public protocol CustodialAccountBalanceType: SingleAccountBalanceType {
    var withdrawable: MoneyValue { get }
    var pending: MoneyValue { get }
}
