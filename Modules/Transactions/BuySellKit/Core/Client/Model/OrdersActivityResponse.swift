//
//  OrdersActivityResponse.swift
//  BuySellKit
//
//  Created by Alex McGregor on 7/31/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct OrdersActivityResponse: Decodable {
    let items: [FiatActivityItemEvent]
}
