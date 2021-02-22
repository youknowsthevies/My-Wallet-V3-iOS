//
//  TabSwapping.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 7/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol TabSwapping: class {
    func send(from account: BlockchainAccount)
    func switchToSend()
    func switchTabToSwap()
    func switchTabToReceive()
    func switchToActivity(currency: CryptoCurrency)
}
