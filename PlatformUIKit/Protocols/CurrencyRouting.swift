//
//  CurrencyRouting.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 7/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol CurrencyRouting: class {
    func toSend(_ currency: CryptoCurrency)
    func toReceive(_ currency: CryptoCurrency)
}
