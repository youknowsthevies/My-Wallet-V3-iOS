//
//  WithdrawFeesResponse.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 19/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

struct CurrencyFeeResponse: Decodable {
    let symbol: String
    let value: String
}

struct WithdrawFeesResponse: Decodable {
    let fees: [CurrencyFeeResponse]
    let minAmounts: [CurrencyFeeResponse]
}
