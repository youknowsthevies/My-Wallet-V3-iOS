//
//  SendScreenProvider.swift
//  TransactionUIKit
//
//  Created by Paulo on 03/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import UIKit

public protocol SendScreenProvider: AnyObject {
    func send(_ cryptoCurrency: CryptoCurrency) -> UIViewController
}
