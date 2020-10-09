//
//  SendRouterAPI.swift
//  TransactionKit
//
//  Created by Paulo on 03/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol SendRouterAPI {
    func send(account: BlockchainAccount)
}
